if !has('python')
    echo "Error: vim linemotion required vim compiled with +python"
    finish
endif

"nmap <leader>h :call LMGoLeft()<CR>
"nmap <leader>l :call LMGoRight()<CR>

command! -nargs=0 -bar Lright call s:LineMotionGoRight()
command! -nargs=0 -bar Lleft call s:LineMotionGoLeft()

python << EOF

import tempfile, os
TMP_FILE = tempfile.mktemp(suffix=str(os.getpid()), prefix='vim-linemotion_')
def get_last_info():
    import datetime, time
    import vim
    if os.path.exists(TMP_FILE):
        file_t = time.localtime(os.stat(TMP_FILE).st_mtime)
        target_t = (datetime.datetime.now() - datetime.timedelta(seconds=10)).timetuple()
        if file_t < target_t:
            return None

        f_handler = open(TMP_FILE, 'r')
        cursor = f_handler.read()
        f_handler.close()
        if cursor.split(',')[0] == str(vim.current.window.cursor[0]):
            return cursor
        else:
            return None
    else:
        return None

def set_last_info(info):
    f_handler = open(TMP_FILE, 'w')
    f_handler.write(info)
    f_handler.close()

def change_direction(direction):
    import vim
    last_info = get_last_info()
    line_lenth = len(vim.current.line)
    c_cursor = vim.current.window.cursor
    if not last_info:
        vim.current.window.cursor = (c_cursor[0],line_lenth/2)
        current_info = "%s,%s" % vim.current.window.cursor
        set_last_info(current_info + ',0.5')
    else:
        last_off_set = last_info.split(',')[2]
        last_position = last_info.split(',')[1]
        off_set = int(line_lenth * (float(last_off_set)/2))

        if direction == 'right':
            vim.current.window.cursor = (c_cursor[0],int(last_position) + off_set)
        else:
            vim.current.window.cursor = (c_cursor[0],int(last_position) - off_set)

        current_info = "%s,%s" % vim.current.window.cursor
        set_last_info(current_info + ',' + str(float(last_off_set)/2))
EOF

function! s:LineMotionGoLeft()

python << EOF
change_direction('left')
EOF
endfunction

function! s:LineMotionGoRight()
python << EOF
change_direction('right')
EOF
endfunction

syn region String start=/\('''\|"""\)/ end=/\('''\|"""\)/ fold
set foldtext=getline(v:foldstart+1)

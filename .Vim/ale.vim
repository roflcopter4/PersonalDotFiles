scriptencoding utf-8
let g:ale_sign_error = get(g:, 'spacevim_error_symbol', '✖')
let g:ale_sign_warning = get(g:,'spacevim_warning_symbol', '➤')
let g:ale_sign_info = get(g:,'spacevim_info_symbol', '-')
let g:ale_echo_msg_format = get(g:, 'ale_echo_msg_format', '%severity%: %linter%: %s')

"highlight link ALEErrorSign GruvboxRedSign
"highlight link ALEWarningSign GruvboxYellowSign

let g:ale_lint_on_text_changed = 'always'
let g:ale_lint_delay = 500

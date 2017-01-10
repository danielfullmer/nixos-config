let opts = {}
let opts.path_to_nixpkgs = '/home/danielrf/nixpkgs'
let opts.cache_file = '/tmp/export-vim-plugin-for-nix-cache-file'
let opts.plugin_dictionaries = map(readfile("./plugin-names"), 'eval(v:val)')
" add more files
" let opts.plugin_dictionaries += map(.. other file )
call nix#ExportPluginsForNix(opts)

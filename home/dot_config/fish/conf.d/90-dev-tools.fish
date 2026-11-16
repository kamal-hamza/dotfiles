# Machine-specific dev tool env (NOT tracked by chezmoi) - each file is
# copied by hand from the *.fish.example files. See dev-tools/README.md.
for f in $__fish_config_dir/dev-tools/*.fish
    test -r $f; and source $f
end

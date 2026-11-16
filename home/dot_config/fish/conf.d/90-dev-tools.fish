# Machine-specific dev tool env (NOT tracked by chezmoi) - managed with
# `dev-tool {list,add,edit,remove,show}`. See dev-tools/README.md.
for f in $__fish_config_dir/dev-tools/*.fish
    test -r $f; and source $f
end

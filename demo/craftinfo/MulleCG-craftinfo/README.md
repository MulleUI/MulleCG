# MulleCG-craftinfo

Craftinfo for mulle-sde to build [MulleCG](//github.com/<|GITHUB_USER|>/MulleCG)

```
mulle-sde dependency add --github <|GITHUB_USER|> MulleCG
mulle-sde dependency mark MulleCG singlephase
# mulle-sde dependency set MulleCG aliases MulleCG-other
# mulle-sde dependency set MulleCG include MulleCG-other.h
# mulle-sde environment --global set MULLE_CRAFT_USE_SCRIPT YES
```

## Tips

* If you want to define `CFLAGS` use `definition/set/append/CFLAGS` instead of `definition/set/CFLAGS` so that you can still add flags with the environment variable `CFLAGS`. Or use `mulle-sde dependency craftinfo  set --append MulleCG CFLAGS "-DX=0`
* use `CPPFLAGS` instead of `CFLAGS` to match C++, C and Objective-C
* you can use `definition/set/append0` to append a string without an intervening space
* you can use `definition/set/remove` to remove a definition


<!--
extension : mulle-sde/craftinfo
directory : project/all
template  : .../README.md
Suppress this comment with `export MULLE_SDE_GENERATE_FILE_COMMENTS=NO`
-->

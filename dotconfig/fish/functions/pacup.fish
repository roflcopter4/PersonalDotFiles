function pacup --description alias\ pacup=sudo\ \\pacman\ --color=always\ -Syu
	command sudo pacman --color=always -Syu $argv;
end

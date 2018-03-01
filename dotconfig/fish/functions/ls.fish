
function ls
	set -lx LC_ALL C 
	command ls -B -H --color --group-directories-first $argv;
end

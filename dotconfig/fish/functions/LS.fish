
function LS --description alias\ LS=LC_ALL=C\ \\ls\ -H\ --group-directories-first
	set -lx LC_ALL C 
	command ls -H --group-directories-first $argv;
end

#!/bin/bash

dst() {
	p=${2:0:2}
	 echo ${p,,}${2:2:-1}
}

>stubs_386.s
>stubs_arm.s

grep -h TEXT *_amd64.s |while read line; do
	d=$(dst $line)
	echo -e "$line\n\tJMP\t$d" >>stubs_386.s
	echo -e "$line\n\tB\t$d" >>stubs_arm.s
done

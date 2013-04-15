#/bin/bash
VALGRIND=valgrind
TESTDIR=../tests
BINFILE=./tp1
EXT=".out"

OK=1
OKVALGRIND=1
for i in $( ls $TESTDIR/*.in); do
	echo testeando $i
	$VALGRIND --show-reachable=yes --leak-check=yes --error-exitcode=1 -q $BINFILE -f $i
	if [ $? != "0" ]; then
		OKVALGRIND=0
	fi
	CATEDRA=${i/in/catedra.out}
	ALUMNO=$i$EXT
	diff -q $CATEDRA $ALUMNO
	if [ $? != "0" ]; then
		OK=0
	fi
done
if [ $OK != "0" ] && [ $OKVALGRIND != "0" ]; then
	echo "Tests finalizados correctamente"
fi



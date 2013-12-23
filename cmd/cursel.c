
/*
By way of Russ Cox:
	https://groups.google.com/forum/#!topic/plan9port-dev/u-Lb1Ds1DBg
*/


#include <u.h>
#include <libc.h>
#include <thread.h>
#include <9pclient.h>
#include <acme.h>

void
threadmain(int argc, char **argv)
{
	int id;
	uint q0, q1;
	Win *w;

	USED(argc);
	USED(argv);
	
	id = atoi(getenv("winid"));
	w = openwin(id, nil);
	if(w == nil)
		sysfatal("openwin: %r");
	winreadaddr(w, nil); // open file
	winctl(w, "addr=dot");
	q0 = winreadaddr(w, &q1);
	print("#%d,#%d\n", q0, q1);
	threadexitsall(nil);
}

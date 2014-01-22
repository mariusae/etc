#include <u.h>

#include "/usr/local/include/zookeeper/zookeeper.h"

#include <signal.h>
#include <libc.h>
#include <bio.h>
#include <fcall.h>

void
usage()
{
	fprint(2, "usage: zk [-h hostlist] [-D] cmd args...\n");
	exits("usage");
}

void xread(int, char**);
void xwrite(int, char**);
void xls(int, char**);
void xrm(int, char**);

void zklog(const char*);
void zfatal(char*, int);

char *hostlist = "localhost:2181";
int chatty = 0;
zhandle_t *zh = nil;

void
main(int argc, char **argv)
{
	ARGBEGIN{
	case 'h':
		hostlist = EARGF(usage());
		break;
	case 'D':
		chatty = 1;
		break;
	default:
		usage();
	}ARGEND

	if(argc < 1)
		usage();

	zh = zookeeper_init2(hostlist, 0, 10000, 0, 0, 0, zklog);
	if(zh == nil){
		fprint(2, "zk init");
		exits("zk");
	}

	if(strcmp("read", argv[0]) == 0)
		xread(argc, argv);
	else if(strcmp("write", argv[0]) == 0)
		xwrite(argc, argv);
	else if(strcmp("ls", argv[0]) == 0)
		xls(argc, argv);
	else if(strcmp("rm", argv[0]) == 0)
		xrm(argc, argv);
	else
		usage();
	
	exits(0);
}

void
xread(int argc, char **argv)
{
	char buf[2<<19];
	int n = sizeof(buf), rv;

	memset(buf, 0, sizeof(buf));

	if(argc < 2)
		usage();

	if((rv=zoo_get(zh, argv[1], 0, buf, &n, nil)) != ZOK)
		zfatal("zoo_get", rv);

	if(n > 0 && write(1, buf, n) < 0)
		sysfatal("write error: %r");

	exits(0);
}

void
xwrite(int argc, char **argv)
{
	char buf[2<<19];
	int n = sizeof(buf), m, rv;
	
	if(argc < 2)
		usage();
		
	/* Truncate first; best effort! */
	zoo_delete(zh, argv[1], -1);

	m = readn(0, buf, n);
	if(m < 0)
		sysfatal("read: %r");
	if(m == n){
		fprint(2, "input too big\n");
		exits("toobig");
	}

	if((rv = zoo_create(zh, argv[1], buf, m, &ZOO_OPEN_ACL_UNSAFE, 0, 0, 0)) != ZOK)
		zfatal("zoo_create", rv);
}

void 
xls(int argc, char **argv)
{
	struct String_vector cs;
	int rv, i;
	char *sep = "/";

	if(argc < 2)
		usage();
	
	if(argv[1][0] != '\0' && argv[1][strlen(argv[1])-1] == '/')
		sep = "";

	if((rv=zoo_get_children(zh, argv[1], 0, &cs)) != ZOK)
		zfatal("zoo_get_children", rv);

	for(i=0; i<cs.count; i++)
		fprint(1, "%s%s%s\n", argv[1], sep, cs.data[i]);
}

void 
xrm(int argc, char **argv)
{
	int rv;

	if(argc < 2)
		usage();
		
	if((rv=zoo_delete(zh, argv[1], -1)) != ZOK)
		zfatal("zoo_delete", rv);
}

void
zklog(const char *message)
{
	if(!chatty)
		return;
	
	fprint(2, "zk: %s\n", message);
}

void
zfatal(char *which, int rv)
{
	sysfatal("%s: %s", which, zerror(rv));
}

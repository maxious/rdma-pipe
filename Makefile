CC=gcc
CFLAGS=-fopenmp -O2 -Wall -Werror
INCLUDES=
LDFLAGS=
LIBS=-lrdmacm -libverbs -pthread

SRCS=rdsend.c rdrecv.c
OBJS=$(SRCS:.c=.o)
PROG=rdsend rdrecv

all: $(PROG)

debug: CFLAGS=-Wall -Werror -g -DDEBUG
debug: $(PROG)

.c.o:
	$(CC) $(CFLAGS) $(INCLUDES) -c -o $@ $<

rdsend: $(OBJS)
	$(CC) $(CFLAGS) $(INCLUDES) -o $@ $@.o $(LDFLAGS) $(LIBS)

rdrecv: $(OBJS)
	$(CC) $(CFLAGS) $(INCLUDES) -o $@ $@.o $(LDFLAGS) $(LIBS)

clean:
	$(RM) *.o *~ $(PROG)

install: $(PROG)
	install -m 0755 $(PROG) rdcp rdpipe /usr/local/bin
	@echo 'WARNING: rdsend/rdrecv pin about 16 MB, so ibv_reg_mr fails when ulimit -l is below that (currently: $(shell ulimit -l) kB).'
	@echo 'As root, create /etc/security/limits.d/rdma.conf containing:'
	@echo '  * soft memlock unlimited'
	@echo '  * hard memlock unlimited'
	@echo 'Then log back in for the new limits to apply.'

uninstall:
	cd /usr/local/bin && $(RM) $(PROG) rdcp rdpipe 

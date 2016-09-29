TARGET = cacu
DIRS = sub add .

CFLAGS = -O2 -Iadd -Isub 
FILES = $(foreach dir, $(DIRS), $(wildcard $(dir)/*.c))
OBJS = $(patsubst %.c,%.o,$(FILES))
$(TARGET):$(OBJS)
	$(CC) -g -o $(TARGET) $(OBJS)

clean:
	-$(RM) $(TARGET) $(OBJS)

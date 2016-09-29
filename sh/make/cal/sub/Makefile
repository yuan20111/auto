OBJS=sub_int.o sub_float.o

all:$(OBJS)
$(OBJS):%.o:%.c
	$(CC) -c $< -o $(OBJSDIR)/$@ $(CFLAFS)

clean: 
	$(RM) $(OBJS)

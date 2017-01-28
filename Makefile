TARGET = gui

SOURCES = $(wildcard *.c)

OBJECTS = $(subst .c,.o,$(SOURCES))

CC = gcc

$(TARGET): $(OBJECTS)
	$(CC) -g $(OBJECTS) -o $(TARGET) `pkg-config --cflags --libs gtk+-3.0`

%.o: %.c
	$(CC) -Wall -g -c -o $@ $< `pkg-config --cflags --libs gtk+-3.0`

.PHONY: clean
clean:
	-rm -f $(TARGET) $(OBJECTS)

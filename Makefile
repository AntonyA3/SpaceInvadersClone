
CC=g++
CFLAGS = -I ./include -Wall -g
SRCDIR = ./src/
LIBS = -lgdi32 -lglu32 -lopengl32 -lglew32 -lglfw3 -llua
OBJ = $(patsubst $(SRCDIR)%.cpp,%.o,$(wildcard ./src/*.cpp))

%.o: $(SRCDIR)%.cpp
	$(CC) $< -c $(CFLAGS)

install: $(OBJ)
	$(CC) -o spaceInvaders.exe $(CFLAGS) $(OBJ) $(LIBS) 

run:
	.\spaceInvaders.exe
	
clean:
	-rm *o spaceInvaders.exe

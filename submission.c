#include "submission.h"
#include <stdlib.h>


/* foo.h

#ifndef FOO_H_   /* Include guard */
/*
#define FOO_H_

int foo(int x);  /* An example function declaration */
/*
#endif // FOO_H_
foo.c

#include "foo.h"  /* Include the header (not strictly necessary here) */
/*
int foo(int x)    /* Function definition */
//{
//    return x + 5;
//}
//main.c

//#include <stdio.h>
///#include "foo.h"  /* Include the header here, to obtain the function declaration */

//int main(void)
//{
 //   int y = foo(3);  /* Use the function here */
  //  printf("%d\n", y);
   // return 0;
//}
//To compile using GCC

//gcc -o my_app main.c foo.c
struct image {
	int width;
	int height;
	int** cells; 
}

struct video {
	struct image val;
    struct node * next;
} 

struct image* createWhiteImg(unsigned int width,unsigned int height) {
	
	int i, **array;
	array = malloc(width*sizeof(int*));
	for(i=0;i<width;i++) array[i] = malloc(height*sizeof(int));

	struct image img = malloc(sizeof(image));
	img.cells = array;
	img.width = width;
	img.height = height;

	return &img;

}

void setPixel( struct image* img,un signed int x,unsigned int y,unsigned char grayscale) {

}

unsigned char getPixel( struct image *img,unsigned int x,unsigned int y) {

}

struct video *createEmptyFrameList() {

}

struct video *insertFrameUpFront( struct video *video, struct image *img) { 

}

struct image *getNthFrame( struct video *video, int frameNo){

}

struct video *deleteNthFrame( struct video *video, int frameNo) {

}

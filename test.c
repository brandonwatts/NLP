#include <stdlib.h>
#include <stdio.h>
#include "submission.h"

 int main() {
 struct image *a=createWhiteImg(16,9);
 struct image *b=createWhiteImg(16,9);
 struct image *c=createWhiteImg(16,9);
 /*setPixel(a,0,0,14);
 setPixel(b,15,8,28);
 setPixel(c,10,4,54);
 struct image *d=NULL;
 struct video *v=createEmptyFrameList();
 v =insertFrameUpFront(v,c);
 v =insertFrameUpFront(v,b);
 v =insertFrameUpFront(v,a);
 v =deleteNthFrame(v,1);
 d =getNthFrame(v,1);
 unsigned char px=getPixel(d,10,4);
 if (px==54)
 	printf("WORKS\n");
 else
 	printf("BUMMER\n");
 return 0;*/
}
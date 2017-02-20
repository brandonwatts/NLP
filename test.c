#include <stdlib.h>
#include <stdio.h>
#include "submission.h"

void printImageVals(struct image* img,int width,int height) {
	 int i,j;
	 for (i = 0; i < width; i++) {
      for (j = 0; j < height; j++) {
            printf("%d ", img->cells[i][j]);
        }
        printf("\n");
    }
}

 int main() {
 struct image *a=createWhiteImg(16,9);
 struct image *b=createWhiteImg(16,9);
 struct image *c=createWhiteImg(16,9);
 setPixel(a,0,8,14);
 printImageVals(a,16,9);
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
 	printf("BUMMER PX is: %d\n",px);
 	
 return 0;

}




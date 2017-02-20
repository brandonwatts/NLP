#include "submission.h"
#include <stdlib.h>


/**  Method that will create a white image of a specified size.
*
*  @param width   Width of our image we wish to create.
*  @param height  Height of our image we wish to create.
*  @return 		  Pointer to the image.
**/
struct image* createWhiteImg(unsigned int width,unsigned int height) {

	/** Allocate a 2-D array with calloc so it initializes all cells to 0 **/
	int** array = calloc(width,sizeof(int*));

	int i;

	/** Interate over each row and Allocate it a hieght **/
	for(i=0;i<width;i++) array[i] = calloc(height, sizeof(int));

	/** Make the image white **/
	int k,j;
	for(k = 0; k < width; k++)
	{
		for (j = 0; j < height; j++)
		{
			array[k][j] = 255;
		}
	}

	/** Allocate enough space for our image **/
	struct image* img = malloc(sizeof(struct image));

	/** Initialize all the image member variables **/
	img->cells = array;
	img->width = width;
	img->height = height;

	return img;
}

/**  Method that set a given pixel of a specified Image.
*
*  @param img     	 Pointer to the specifeid image.
*  @param x  		 X position of our pixel.
*  @param y			 Y position of our pixel.
*  @param greyscale  Greyscale value we wish to give the image.
**/
void setPixel( struct image* img, unsigned int x,unsigned int y,unsigned char grayscale) {
		img->cells[x][y] = grayscale;
}

/**  Method that will retrieve the Greyscale value of a specific pixel.
*
*  @param img  Pointer to the specified image.
*  @param X    X Position of our pixel.
*  @param Y    Y position of our pixel.
*  @return     Greyscale value at that point.
**/
unsigned char getPixel( struct image* img,unsigned int x,unsigned int y) {
   	return img->cells[x][y];
}

/**  Method that will create a video.
*
*  @return  Pointer to the video.
**/
struct video* createEmptyFrameList() {

	/** Allocate a video on the heap **/
	struct video *vid = malloc(sizeof(struct video));

	/** Allocate a "blank frame" **/
	struct frame* imgFrame = malloc(sizeof(struct frame));

	/** Populate our "blank frame" **/
	imgFrame -> img = NULL;
	imgFrame -> next = NULL;

	/** Set the video length to 0 **/
	vid->length = 0 ;

	return vid;
}

/**  Method that insert a frame to the front of our video.
*
*  @param video  Pointer to the specified video.
*  @param img    Image we wish to insert.
*  @return       Pointer to our video.
**/
struct video* insertFrameUpFront( struct video* video, struct image* img) { 

	/** Allocate an imageFrame on the Heap **/
	struct frame* imgFrame = malloc(sizeof(struct frame));

	/** Increse the length of our video **/
	video->length++;

	/** Set the frames img resource **/
	imgFrame->img = img;

	/** Set the frames next pointer to point at the first frames next pointer **/
	imgFrame->next = video->head;

	/** Set the head to our current frame **/
	video->head = imgFrame;

	return video;
}

/**  Method that return the Nth frame in the video and will return NULL if such a frame does not exist.
*
*  @param video    Pointer to the specified video.
*  @param frameNo  Number of the frame we wish to delete.
*  @return 		   Pointer to the image contained by the frame.
**/
struct image* getNthFrame(struct video* video, int frameNo){

		/** Set the current frame to the first frame of the video **/
		struct frame* current = video->head;

		int i;

		/** Iterate over the frames an look for the frame. If there arent enough frames, we just return null **/
	 	for(i=0;i < frameNo;i++) {

	 		if(current->next == NULL)
	 			return NULL;

	 		current = current->next;
	 	}

	 	/** We are just returning the node, no pointers to update. **/
	 	return current->img;
}

/**  Method that delete a specified frame. It returns null if such a frame does not exist.
*
*  @param video   Pointer to the video.
*  @param frameNo The Frame Number we wish to delete.
*  @return 		  Pointer to the Video after deletion of the frame.
**/
struct video* deleteNthFrame( struct video* video, int frameNo) {
	
	/** We use a temp node to update pointers **/
	struct frame* tempFrame = NULL;

	/** Set the current frame to the first frame of the video **/
	struct frame* current = video->head;

	int i;

	/** Iterate over the frames an look for the frame. If there arent enough frames, we just return null **/
	for(i=0;i < frameNo-1;i++) {
	 		
		if(current->next == NULL)
	 			return NULL;
	 	current = current->next;
	}

	/** Set our temp node pointer to the current frames next frame. **/
	tempFrame = current->next;

	/** Set the currents frames pointer to go around tempFrame **/
	current->next = tempFrame->next;

	/** Decrease the videos frames by 1 **/
	video->length--;

	/** Free that frame so we dont get memory leaks **/
	free(tempFrame);

	return video;
}

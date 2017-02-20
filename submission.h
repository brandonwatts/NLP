/** Structure to store an image **/
struct image{
	int width;
	int height;
	int** cells; 
};

/** Structure to store a frame **/
struct frame{
	struct image* img;
	struct frame* next;
};

/** Structure to store frames **/
struct video{
	struct frame* head;
	int length;
};

struct image* createWhiteImg(unsigned int width,unsigned int height);
void setPixel(struct image* img, unsigned int x, unsigned int y, unsigned char grayscale);
unsigned char getPixel( struct image* img,unsigned int x,unsigned int y);
struct video* createEmptyFrameList();
struct video* insertFrameUpFront( struct video* video, struct image *img);
struct image* getNthFrame( struct video* video, int frameNo);
struct video* deleteNthFrame( struct video* video, int frameNo);

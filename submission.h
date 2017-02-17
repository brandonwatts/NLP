


struct image* createWhiteImg(unsigned int width,unsigned int height);
void setPixel(struct image* img, unsigned int x, unsigned int y,
unsigned char grayscale);
unsigned char getPixel( struct image *img,unsigned int x,unsigned int y);
struct video *createEmptyFrameList();
struct video *insertFrameUpFront( struct video *video, struct image *img);
struct image *getNthFrame( struct video *video, int frameNo);
struct video *deleteNthFrame( struct video *video, int frameNo);

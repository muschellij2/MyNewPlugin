//
//  MyNewPluginFilter.m
//  MyNewPlugin
//
//  Copyright (c) 2015 John. All rights reserved.
//

#import "MyNewPluginFilter.h"

@implementation MyNewPluginFilter
@synthesize window;


- (void) initPlugin
{
}

//    Called at run
- (long) filterImage:(NSString*) menuName
{

    return [self roiAutoSetPixels];
    
//    NSMutableArray *roiSeriesList;
//    NSMutableArray *roiImageList;
//    roiSeriesList=[viewerController roiList];
//    roiImageList=[roiSeriesList objectAtIndex:0];
//    NSArray *pixList = [viewerController pixList];
    
}


- (long) duplicateWindow
{
    ViewerController	*new2DViewer;
    
	// In this plugin, we will simply duplicate the current 2D window!

    new2DViewer = [self duplicateCurrent2DViewerWindow];
    
	if( new2DViewer) return 0; // No Errors
	else return -1;

}

- (long) roiAutoSetPixelsAll
{
    NSMutableArray *roiList = [viewerController roiList];
    
    ROI *curROI;
    
    int i=0;
    while ([roiList[i] count] == 0 && i<[roiList count]) {
        i=i+1;
    }
    
    curROI=[roiList[i] objectAtIndex:0];
    
    if([curROI type] == tPencil){

    float min = -100000;
    float max = 100000;
    
//    Plugin cannot run
//    max = [[pixList[i] objectAtIndex: 0] maxValueOfSeries];
//    min = [[pixList[i] objectAtIndex: 0] minValueOfSeries];
    
//    Outside
    [viewerController roiSetPixels:curROI :2 :false :true :min :max :0];
//    Inside
    [viewerController roiSetPixels:curROI :1 :false :false :min :max :1];
    
//    Window
    [[viewerController imageView] setWLWW:0 :1];
    
    return 0;
    }else return 1;
}

- (long) roiAutoSetPixels
{
    NSMutableArray *roiList = [viewerController roiList];
    NSArray *roiNames = [viewerController roiNames];
    ROI *curROI;
    
    float min = -100000;
    float max = 100000;
    
    BOOL outside = true;
    
    for (int i=0; i<[roiList count]; i++)
    {
        if ([roiList[i] count] != 0)
        {
            for (int j=0; j<[roiList[i] count]; j++)
            {
                curROI=[roiList[i] objectAtIndex:j];
                long roiType = [curROI type];
                
//                 // Check ROI type
//                NSString *roiTypeCheck = [NSString stringWithFormat:@"%li", roiType];
//                NSAlert *alert = [[NSAlert alloc] init];
//                [alert setInformativeText:roiTypeCheck];
//                [alert runModal];
                
                if (roiType == tPencil || roiType == tCPolygon)
                {
                    if (outside)
                    {
                        [viewerController roiSetPixels:curROI :2 :false :true :min :max :0];
                        outside=false;
                    }
                    
                    int index = [roiNames indexOfObject:[curROI name]];
                    int newValue = index+1;
                    
                    [viewerController roiSetPixels:curROI :0 :false :false :min :max :newValue];
                }
            }
        }
    }
    
    [[viewerController imageView] setWLWW:0 :1];
    [self openExportWindow];
    return 0;
}

- (void) openExportWindow
{
    window = [[NSWindowController alloc] initWithWindowNibName:@"Window.xib"];
    [window showWindow:self];
}

- (IBAction)exportButton:(id)sender
{
    
}



















@end
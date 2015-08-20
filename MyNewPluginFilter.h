//
//  MyNewPluginFilter.h
//  MyNewPlugin
//
//  Copyright (c) 2015 John. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OsiriXAPI/PluginFilter.h>
#import <OsiriXAPI/BrowserController.h>
#import <OsiriXAPI/DICOMExport.h>
#import <OsiriXAPI/DicomDatabase.h>
#import <OsiriXAPI/DCMView.h>
#import <OsiriXAPI/MyOutlineView.h>
#import <OsiriXAPI/NSThread+N2.h>
#import <OsiriXAPI/ThreadsManager.h>
#import <OsiriXAPI/ITKSegmentation3DController.h>
#import <OsiriXAPI/N2Stuff.h>


@interface MyNewPluginFilter : PluginFilter {
    
    IBOutlet NSWindow *window;
    IBOutlet NSTextField *fileNameField;
    NSString *fileName;
    NSString *filePath;
    NSMutableArray *tableArray;
    //    NSMutableArray *roiImageList;
    NSMutableArray *dcmPixList;
    BrowserController *currentBrowser;
    DCMView *imageView;
    NSMutableArray *roiList;
    NSMutableArray *pixList;
    NSWindowController *windowCon;
    NSFileManager *fileManager;
    NSMatrix *oMatrix;
    
    
}

- (long) filterImage:(NSString*) menuName;
- (long) duplicateWindow;
//- (long) roiAutoSetPixelsAll;
- (long) roiAutoSetPixels;


- (IBAction) exportButton:(id)sender;
- (IBAction) cancelButton:(id)sender;
- (void) openExportWindow;

- (void) writeFile;
- (void) viewerExportToDICOM;
- (void) browserExportToDICOM;

@end

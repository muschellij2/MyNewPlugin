//
//  MyNewPluginFilter.h
//  MyNewPlugin
//
//  Copyright (c) 2015 John. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OsiriXAPI/PluginFilter.h>

@interface MyNewPluginFilter : PluginFilter {
    
    NSWindowController *window;
    
}

- (long) filterImage:(NSString*) menuName;
- (long) duplicateWindow;
- (long) roiAutoSetPixelsAll;
- (long) roiAutoSetPixels;

@property(assign) IBOutlet NSWindowController *window;

- (IBAction)exportButton:(id)sender;
- (void) openExportWindow;

@end

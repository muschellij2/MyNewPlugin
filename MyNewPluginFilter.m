//
//  MyNewPluginFilter.m
//  MyNewPlugin
//
//  Copyright (c) 2015 John. All rights reserved.
//

#import "MyNewPluginFilter.h"

@implementation MyNewPluginFilter


- (void) initPlugin
{
}

//    Called at run
- (long) filterImage:(NSString*) menuName
{
    //    roiImageList=[roiList objectAtIndex:0];
    currentBrowser = [BrowserController currentBrowser];
    imageView = [viewerController imageView];
    dcmPixList = [imageView dcmPixList];
    pixList = [viewerController pixList];
    roiList = [viewerController roiList];
    fileManager = [[NSFileManager alloc]init];
    oMatrix = [[BrowserController currentBrowser] oMatrix];
    
    return [self roiAutoSetPixels];
}


- (long) duplicateWindow
{
    ViewerController	*new2DViewer;
    
	// In this plugin, we will simply duplicate the current 2D window!

    new2DViewer = [self duplicateCurrent2DViewerWindow];
    
	if( new2DViewer) return 0; // No Errors
	else return -1;

}

//   Only certain ROI's, pixel value based on name
- (long) roiAutoSetPixels
{
    NSArray *roiNames = [viewerController roiNames];
    ROI *curROI;
    
    
    tableArray = [[NSMutableArray alloc] init];
    
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
//                long roiType = [curROI type];
                
//                 // Check ROI type
//                NSString *roiTypeCheck = [NSString stringWithFormat:@"%li", roiType];
//                NSAlert *alert = [[NSAlert alloc] init];
//                [alert setInformativeText:roiTypeCheck];
//                [alert runModal];
                
//                if (roiType == tPencil || roiType == tCPolygon)
//                {
                    if (outside)
                    {
                        [viewerController roiSetPixels:curROI :2 :false :true :min :max :0];
                        outside=false;
                    }
                    
                    int index = [roiNames indexOfObject:[curROI name]];
//                    int newValue = index+1;
                    int newValue = 1;
                    NSString *newValueString = [NSString stringWithFormat:@"%d",newValue];
                    
                    [viewerController roiSetPixels:curROI :0 :false :false :min :max :newValue];
                    
                    if (![tableArray containsObject:@{@"name" : [curROI name], @"pixel" : newValueString}])
                    {
                        
                        [tableArray addObject:@{@"name" : [curROI name], @"pixel" : newValueString}];
                    }
//                }
            }
        }
    }
    
    [[viewerController imageView] setWLWW:0 :1];
    
//    [self openExportWindow];
//    fileName = @"ROI";
//    [window close];
    
//    [self viewerExportToDICOM];
    return 0;
}

- (void) openExportWindow
{
    windowCon = [[NSWindowController alloc] initWithWindowNibName:@"Window" owner:self];
    [windowCon showWindow:self];
    [window makeKeyAndOrderFront:self];
}

- (IBAction) exportButton:(id)sender
{
//     fileName = [fileNameField stringValue];
    fileName = @"ROI";
    [window close];
    
    [self viewerExportToDICOM];
//    NSArray *viewers = [ViewerController getDisplayed2DViewers];
//    [[viewers objectAtIndex:0]exportDICOMFile:[viewers objectAtIndex:0]];

//    [self browserExportToDICOM];
//    [currentBrowser exportDICOMFile:self];
    
}

- (IBAction) cancelButton:(id)sender
{
    [window close];
}

- (void) writeFile
{
    if (filePath==nil)
    {
//        Temporary code
        filePath = @"Users/natalieullman/Desktop/";
    }
    NSString *filePathName = [NSString stringWithFormat:@"%@/%@.txt",filePath,fileName];
    NSString *tableString = @"Name\tPixel Value\n";
    NSString *temp = @"";
    
    for (int i=0; i<[tableArray count]; i++)
    {
        temp = [[tableArray objectAtIndex:i]objectForKey:@"name"];
        tableString = [tableString stringByAppendingString:temp];
        temp = [[tableArray objectAtIndex:i]objectForKey:@"pixel"];
        tableString = [tableString stringByAppendingFormat:@"\t%@\n",temp];
    }
    
    [fileManager createFileAtPath:filePathName contents:NULL attributes:NULL];
    [tableString writeToFile:filePathName atomically:YES encoding:NSASCIIStringEncoding error:NULL];

}

- (void) viewerExportToDICOM
{
    fileName = @"ROI";
    NSMutableArray *producedFiles = [NSMutableArray array];
    
    int from, to, interval;
    
    from = 0;
    to = [pixList count];
    interval = 1;
    
    int curImage = [imageView curImage];
    
        DICOMExport *exportDCM = [[DICOMExport alloc] init];
        
        [exportDCM setSeriesNumber:5300 + [[NSCalendarDate date] minuteOfHour] + [[NSCalendarDate date] secondOfMinute]];
        [exportDCM setSeriesDescription: fileName];
        
        NSLog( @"export start");
        
        for (int i = from ; i < to; i += interval)
        {
            NSAutoreleasePool	*pool = [[NSAutoreleasePool alloc] init];
            
            [imageView setIndex:i];
            [imageView sendSyncMessage: 0];
            
            NSDictionary* s = [viewerController exportDICOMFileInt:0 withName:fileName allViewers: NO];
            
            if( [s valueForKey: @"file"])
            {
                [producedFiles addObject: s];
            }
            [pool release];
        }

        [imageView setIndex: curImage];
        [imageView sendSyncMessage: 0];
    
    NSArray *viewers = [ViewerController getDisplayed2DViewers];
    
    for( int i = 0; i < [viewers count]; i++)
        [[[viewers objectAtIndex: i] imageView] setNeedsDisplay: YES];
    
    if( [producedFiles count])
    {
        NSArray *objects = [BrowserController.currentBrowser.database addFilesAtPaths: [producedFiles valueForKey: @"file"]
                                                                    postNotifications: YES
                                                                            dicomOnly: YES
                                                                  rereadExistingItems: YES
                                                                    generatedByOsiriX: YES];
        
        objects = [BrowserController.currentBrowser.database objectsWithIDs: objects];
    }
    
//    **Trying to select the newly made dicom file
    
//    NSInteger *tag = 0;
//    NSString *title = @"";
//    for (int j = 0; j < 5; j++)
//    {
//        title = [[oMatrix.cells objectAtIndex:j]title];
//        if([title isEqualToString:fileName])
//        {
//            tag = [[[oMatrix cells]objectAtIndex:j]tag];
//            [oMatrix selectCellWithTag:tag];
//        }
//    }

//    [self browserExportToDICOM];
}

- (void) browserExportToDICOM
{
    NSOpenPanel *sPanel = [NSOpenPanel openPanel];
    currentBrowser = [BrowserController currentBrowser];
    [sPanel setCanChooseDirectories:YES];
    [sPanel setCanChooseFiles:NO];
    [sPanel setAllowsMultipleSelection:NO];
    [sPanel setMessage: NSLocalizedString(@"Select the location where to export the DICOM files:",nil)];
    [sPanel setPrompt: NSLocalizedString(@"Choose",nil)];
    [sPanel setTitle: NSLocalizedString(@"Export",nil)];
    [sPanel setCanCreateDirectories:YES];
    currentBrowser.passwordForExportEncryption = @"";
    
    if ([sPanel runModal] == NSFileHandlingPanelOKButton)
    {        
        [sPanel makeFirstResponder: nil];
        NSMutableArray *dicomFiles2Export = [NSMutableArray array];
        NSMutableArray *filesToExport;
    
//        **Exports only the one you have selected
//        filesToExport = [currentBrowser filesForDatabaseMatrixSelection: dicomFiles2Export onlyImages: NO];
        
//        **Exports all from current matrix view
        filesToExport = [currentBrowser filesForDatabaseOutlineSelection: dicomFiles2Export onlyImages: NO];
        
        NSPredicate *predicate = nil;
            
            @try
            {
                predicate = [NSPredicate predicateWithFormat: @"!(series.name CONTAINS[c] %@) AND !(series.id == %@)", @"OsiriX ROI SR", @"5002"];
                dicomFiles2Export = [[[dicomFiles2Export filteredArrayUsingPredicate: predicate] mutableCopy] autorelease];
                
                predicate = [NSPredicate predicateWithFormat: @"!(series.name CONTAINS[c] %@) AND !(series.id == %@)", @"OsiriX Report SR", @"5003"];
                dicomFiles2Export = [[[dicomFiles2Export filteredArrayUsingPredicate: predicate] mutableCopy] autorelease];
                
                predicate = [NSPredicate predicateWithFormat: @"!(series.name CONTAINS[c] %@) AND !(series.id == %@)", @"OsiriX Annotations SR", @"5004"];
                dicomFiles2Export = [[[dicomFiles2Export filteredArrayUsingPredicate: predicate] mutableCopy] autorelease];
                
                predicate = [NSPredicate predicateWithFormat: @"!(series.name CONTAINS[c] %@) AND !(series.id == %@)", @"OsiriX No Autodeletion", @"5005"];
                dicomFiles2Export = [[[dicomFiles2Export filteredArrayUsingPredicate: predicate] mutableCopy] autorelease];
                
                predicate = [NSPredicate predicateWithFormat: @"!(series.name CONTAINS[c] %@) AND !(series.id == %@)", @"OsiriX WindowsState SR", @"5006"];
                dicomFiles2Export = [[[dicomFiles2Export filteredArrayUsingPredicate: predicate] mutableCopy] autorelease];
            }
            @catch (NSException *e)
            {
                N2LogExceptionWithStackTrace(e);
            }
            filesToExport = [[[dicomFiles2Export valueForKey: @"completePath"] mutableCopy] autorelease];
        
        filePath = [[sPanel filenames]objectAtIndex:0];
        filePath = [NSString stringWithFormat:@"%@/%@_Export",filePath,fileName];
        [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];

        NSMutableDictionary *d = [NSMutableDictionary dictionaryWithObjectsAndKeys: filePath, @"location", filesToExport, @"filesToExport", [dicomFiles2Export valueForKey: @"objectID"], @"dicomFiles2Export", nil];
        NSThread* t = [[[NSThread alloc] initWithTarget:currentBrowser selector:@selector(exportDICOMFileInt: ) object: d] autorelease];
        t.name = NSLocalizedString( @"Exporting...", nil);
        t.supportsCancel = YES;
        t.status = N2LocalizedSingularPluralCount( [filesToExport count], NSLocalizedString(@"file", nil), NSLocalizedString(@"files", nil));
        [[ThreadsManager defaultManager] addThreadAndStart: t];
        [self writeFile];
    }
}


@end
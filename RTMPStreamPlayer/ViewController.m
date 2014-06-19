//
//  ViewController.m
//  RTMPStreamPlayer
//
//  Created by Vyacheslav Vdovichenko on 7/11/12.
//  Copyright (c) 2012 The Midnight Coders, Inc. All rights reserved.
//

#import "ViewController.h"
#import "DEBUG.h"
#import "MemoryTicker.h"
#import "MediaStreamPlayer.h"
#import "VideoPlayer.h"


@interface ViewController () <MPIMediaStreamEvent> {
    MemoryTicker            *memoryTicker;
    RTMPClient              *socket;
    MediaStreamPlayer       *player;
}

-(void)sizeMemory:(NSNumber *)memory;
-(void)setDisconnect;
@end


@implementation ViewController

#pragma mark -
#pragma mark  View lifecycle

-(void)viewDidLoad {
    
    //[DebLog setIsActive:YES];
    
    [super viewDidLoad];
    
    memoryTicker = [[MemoryTicker alloc] initWithResponder:self andMethod:@selector(sizeMemory:)];
    memoryTicker.asNumber = YES;
    
    player = nil;
    socket = nil;
    
    echoCancellationOn;
    
    hostTextField.text = @"rtmp://10.0.1.33:1935/live";
    //hostTextField.text = @"rtmp://10.0.1.33:1935/vod";
    //hostTextField.text = @"rtmp://192.168.2.63:1935/live";
    //hostTextField.text = @"rtmp://192.168.2.63:1935/vod";
    //hostTextField.text = @"rtmp://192.168.1.105:1935/live";
    //hostTextField.text = @"rtmp://192.168.2.101:1935/live";
    hostTextField.delegate = self;
    
    //streamTextField.text = @"flv:nachostream1";
    streamTextField.text = @"slavav3";
	streamTextField.delegate = self;
    
}

-(void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark -
#pragma mark Private Methods 

// MEMORY

-(void)sizeMemory:(NSNumber *)memory {
    memoryLabel.text = [NSString stringWithFormat:@"%d", [memory intValue]];
}

// ALERT

-(void)showAlert:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Receive" message:message delegate:self
                                           cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [av show];
    });
}

-(void)doConnect {
    
    FramesPlayer *framesPlayer = [[FramesPlayer alloc] initWithView:previewView];
    framesPlayer.orientation = UIImageOrientationRight;
    //framesPlayer.orientation = UIImageOrientationUp;
    //framesPlayer.orientation = UIImageOrientationLeft;
    
#if 0
    
    player = [[MediaStreamPlayer alloc] init:hostTextField.text];

#else
    
    if (!socket) {
        socket = [[RTMPClient alloc] init:hostTextField.text];
        if (!socket) {
            [self showAlert:@"Socket has not be created"];
            return;
        }
        
        [socket spawnSocketThread];
    }
    
    player = [[MediaStreamPlayer alloc] initWithClient:socket];
    
#endif
    
    player.delegate = self;
    player.player = framesPlayer;
    [player stream:streamTextField.text];    
    
    btnConnect.title = @"Disconnect"; 
}

-(void)doDisconnect {
    [player disconnect];
}

-(void)setDisconnect {
    
    [socket disconnect];
    socket = nil;

    player = nil;
    
    btnConnect.title = @"Connect";
    btnPlay.title = @"Start";
    btnPlay.enabled = NO;
    
    hostTextField.hidden = NO;
    streamTextField.hidden = NO;
    
    previewView.hidden = YES;
    
}

#pragma mark -
#pragma mark Public Methods 

// ACTIONS

-(IBAction)connectControl:(id)sender {
    
    NSLog(@"******************************************** connectControl: host = %@", hostTextField.text);
    
    (!player) ? [self doConnect] : [self doDisconnect];
    
}

-(IBAction)playControl:(id)sender; {
    
    NSLog(@"********************************************* playControl: stream = %@", streamTextField.text);
    
    (player.state != STREAM_PLAYING) ? [player start] : [player pause];
    
}

#pragma mark -
#pragma mark UITextFieldDelegate Methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

#pragma mark -
#pragma mark MPIMediaStreamEvent Methods

-(void)stateChanged:(id)sender state:(MPMediaStreamState)state description:(NSString *)description {
    
    NSLog(@" $$$$$$ <MPIMediaStreamEvent> stateChangedEvent: %d = %@ [%@]", (int)state, description, [NSThread isMainThread]?@"M":@"T");
    
    switch (state) {
            
        case CONN_DISCONNECTED: {
            
            [self setDisconnect];
             
            break;
        }
            
        case STREAM_CREATED: {
            
            [player start];
            
            hostTextField.hidden = YES;
            streamTextField.hidden = YES;
            previewView.hidden = NO;
            
            btnPlay.enabled = YES;
            
            break;
            
        }
            
        case STREAM_PAUSED: {
            
            btnPlay.title = @"Start";
            
            break;
        }
            
        case STREAM_PLAYING: {
            
            if ([description isEqualToString:MP_NETSTREAM_PLAY_STREAM_NOT_FOUND]) {
                
                [player stop];
                [self showAlert:description];
                
                break;
            }
            
            btnPlay.title = @"Pause";
            
            break;
        }
            
        default:
            break;
    }
}

-(void)connectFailed:(id)sender code:(int)code description:(NSString *)description {
    
    NSLog(@" $$$$$$ <MPIMediaStreamEvent> connectFailedEvent: %d = %@ [%@]", code, description, [NSThread isMainThread]?@"M":@"T");
    
    if (!player)
        return;
    
    [self setDisconnect];
    
    [self showAlert:(code == -1) ?
     @"Unable to connect to the server. Make sure the hostname/IP address and port number are valid" :
     [NSString stringWithFormat:@"connectFailedEvent: %@", description]];
}

-(void)metadataReceived:(id)sender event:(NSString *)event metadata:(NSDictionary *)metadata {
    NSLog(@" $$$$$$ <MPIMediaStreamEvent> dataReceived: EVENT: %@, METADATA = %@ [%@]", event, metadata, [NSThread isMainThread]?@"M":@"T");
}

@end

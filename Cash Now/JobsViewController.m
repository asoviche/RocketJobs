//
//  JobsViewController.m
//  Cash Now
//
//  Created by amaury soviche on 08.05.14.
//  Copyright (c) 2014 Amaury Soviche. All rights reserved.
//

#import "JobsViewController.h"
#import "GGDraggableView.h"

@interface JobsViewController ()


@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;



@end

@implementation JobsViewController{
    NSArray *JobsArray;
    NSMutableArray *JobsPicturesArray;
    NSInteger IndexOfCurrentJob;
    
    NSString *dateString;
    NSString *Description;
    NSString *Hour;
    NSString *Price;
    NSString *JobID;
    
    NSMutableArray *ViewsArray;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}



-(void)viewWillAppear:(BOOL)animated{
    
    IndexOfCurrentJob = 0;
    JobsPicturesArray = [[NSMutableArray alloc]init];
    ViewsArray = [[NSMutableArray alloc]init];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Job"];
    JobsArray = [query findObjects];
    NSLog(@"desc : %@", [JobsArray description]);
    
    
    [self createViewsForJobs];
    
    
    //prendre les images de tous les jobs et les mettre dans le array : JobsPicturesArray
    for (int i = 0; i < [JobsArray count]  ; i++) {
        
        PFObject *Job = [JobsArray objectAtIndex:i];
        
        //gestion des images des jobs
        if (Job[@"Picture"]) {
            
            PFFile *userImageFile = Job[@"Picture"];
            [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                if (!error) {
                    UIImage *image = [UIImage imageWithData:imageData];
                    if (image) {
                        
                        [JobsPicturesArray addObject:image];
                        //placer les photos dans les vues
                        GGDraggableView *dragView = ViewsArray[i];
                        [dragView loadImageAndStyle:[UIImage imageWithData:imageData]];
                    }
                    else NSLog(@"erreur");
                    //                    NSLog(@"photo !!!");
                    //
                    
                }
            }];
            
            
        }else{
            UIImage *image = [UIImage imageNamed:@"Unknown.png"];
            [JobsPicturesArray addObject:image];
            NSLog(@"pas de photo");
        }
    }
    
    
    
    // [self changeJobUI];
    
}

-(void)createViewsForJobs{
    //handle all the views for the jobs
    for (int i = 0; i < [JobsArray count]  ; i++) {
        
        //we add a view for each job
        GGDraggableView *dragView= [[GGDraggableView alloc] init];
        dragView.frame = CGRectMake((320 - 200)/2, 80, 200, 100);
        [self.view addSubview:dragView];
        [ViewsArray addObject:dragView];
        
        //fill the view information
        PFObject *JobOnTop = [JobsArray objectAtIndex:i];
        dateString = JobOnTop[@"Date"];
        Description = JobOnTop[@"Description"];
        Hour = JobOnTop[@"Hour"];
        Price = JobOnTop[@"Price"];
        JobID = [JobOnTop objectId];
        
        dragView.LabelDescriptionJob.text =Description;
        dragView.LabelDateJob.text =dateString;
        dragView.LabelPriceJob.text =Price;
        dragView.LabelHourJob.text =Hour;
        dragView.JobID = JobID;
        NSLog(@"id job : %@",JobID);
    }
}

-(void) changeJobUI{
    
    PFObject *JobOnTop = [JobsArray objectAtIndex:IndexOfCurrentJob];
    dateString = JobOnTop[@"Date"];
    Description = JobOnTop[@"Description"];
    Hour = JobOnTop[@"Hour"];
    Price = JobOnTop[@"Price"];
    
    NSLog(@"desc pic : %@", [JobsPicturesArray[IndexOfCurrentJob] description]);
    
    GGDraggableView *dragView = ViewsArray[IndexOfCurrentJob];
    dragView.LabelDescriptionJob.text =Description;
    dragView.LabelDateJob.text =dateString;
    dragView.LabelPriceJob.text =Price;
    dragView.LabelHourJob.text =Hour;
}



/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

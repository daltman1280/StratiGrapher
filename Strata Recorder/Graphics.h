//
//  Graphics.h
//  Strata Recorder
//
//  Created by Don Altman on 11/8/12.
//  Copyright (c) 2012 Don Altman. All rights reserved.
//

#ifndef Strata_Recorder_Graphics_h
#define Strata_Recorder_Graphics_h

#define PPI 160.0
#define VX(x) (x)*PPI+PPI/4.
#define VY(y) -(y)*PPI+self.bounds.size.height-PPI/4.
#define VDX(d) (d)*PPI
#define VDY(d) -(d)*PPI

#define GRID_WIDTH .25

#define UX(x) (x-PPI/4.)/PPI
#define UY(y) -(y-self.bounds.size.height+PPI/4.)/PPI

#endif

//
//  Graphics.h
//  Strata Recorder
//
//  Created by Don Altman on 11/8/12.
//  Copyright (c) 2012 Don Altman. All rights reserved.
//

#ifndef Strata_Recorder_Graphics_h
#define Strata_Recorder_Graphics_h

/*
 Converts between User coordinates (in inches) and screen coordinates (points), which are the Core Graphics units.
 If the user scale is in meters/inch, then divide by user scale to obtain units in inches.
 */

static CGFloat PPI = 132.0;												// pixels per inch (this might be different on iPad Mini)
#pragma unused(PPI)
#define VX(x1) (x1)*PPI+PPI*self.origin.x								// convert user (in meters) to view units (pixels)
#define VY(y1) -(y1)*PPI+self.bounds.size.height-PPI*self.origin.y		// convert user (in meters) to view units (pixels)
#define VDX(d) (d)*PPI													// convert distance in X to view units
#define VDY(d) -(d)*PPI													// convert distance in Y to view units

#define GRID_WIDTH .25													// in inches

#define UX(x1) (x1-PPI*self.origin.x)/PPI								// convert view (pixels) to user units (meters)
#define UY(y1) -(y1-self.bounds.size.height+PPI*self.origin.y)/PPI		// convert view (pixels) to user units (meters)

#define distance(p1,p2) sqrtf((p1.x-p2.x)*(p1.x-p2.x)+(p1.y-p2.y)*(p1.y-p2.y))

#endif

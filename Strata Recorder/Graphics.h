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
 Converts between User coordinates (in inches) and screen coordinates (points, which are the Core Graphics units.
 If the user scale is in meters/inch, then divide by user scale to obtain units in inches.
 */

static CGFloat PPI = 130.0;										// pixels per inch (this might be different on iPad Mini)
#define VX(x) (x)*PPI+PPI*XORIGIN								// convert user (in meters) to view units (pixels)
#define VY(y) -(y)*PPI+self.bounds.size.height-PPI*YORIGIN		// convert user (in meters) to view units (pixels)
#define VDX(d) (d)*PPI											// convert distance in X to view units
#define VDY(d) -(d)*PPI											// convert distance in X to view units

#define GRID_WIDTH .25											// in inches

#define UX(x) (x-PPI*XORIGIN)/PPI								// convert view (pixels) to user units (meters)
#define UY(y) -(y-self.bounds.size.height+PPI*YORIGIN)/PPI		// convert view (pixels) to user units (meters)

#endif

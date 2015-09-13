Program Description:
    ECG Viewer is a Matlab GUI for reviewing, processing, and annotating 
    electrocardiogram (ECG) data files. ECG Viewer offers an annotation database, 
    ECG filtering, beat detection using template matching, and inter-beat interval
    (IBI or RR) filtering. Program was created using Matlab 2008b.

MATLAB Toolbox Dependencies: Toolboxes needed to run certain aspects of ECG Viewer
    1. Database toolbox (needed if created/vieweing annotions)
    2. Wavelet Toolbox (needed if using wavelet filtering)

File Dpendencies: other files needed to run ECg Viewer
    1. fastsmooth.m - signal smoothing function
    2. locateOutliers.m - locates IBI outliers or ectopic beats
    3. makeTemplate.m - function to create a template
    4. matchTemplate.m - template matching function
    5. peakDetect.m - function to detect signal peaks
    6. annotations.mdb - matlab database to hold annotations
    7. avg.mexw32 - compiled function for computing the mean
    8. crosscorr.mexw32 - compiled function for computing cross correlation coef.

Usage and Install Notes:
    1. To take advantage of multi core/proc processing Matlab must must run
       matlabpool command. When loading the GUI ask if you want to use
       multiple cores/processors.
    2. dblclick on ecg plot to add annotion, right click or ctrl click to mark
           file as completed
*** 3. Before using the database feature the first time you must create
       a datasourse in your Windows environment named "ann_db". See
       http://matlab.izmiran.ru/help/toolbox/database/instal12.html#18933.
       This is only done once. This datasource must point to your Access database file.
       Please use the annotations.mdb file supplied as a blank database and rename it if
       needed.
    4. dblclick on list of annotations to get details of that annotation
    5. Use the up and down keyboard arrow keys to move to
       the next(up) and previous (down) outlier. Use left and right to
       move one ECG window back and forward. Note...you must first
       click on a blank area in the ECG plot for these functions to work.

Contact Information:
    John T. Ramshur
    University of Memphis
    Department of Biomedical Engineering
    Memphis, TN
    jramshur@gmail.com
    jramshur@memphis.edu

Copyright Information:

    Copyright (C) 2010, John T. Ramshur

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.


THE MODIFICATIONS FOR VERSION 2.0
	* First, we will use a floating-window to process the frames incrementally.
	* Second, we will use a regression model to follow the window in order to avoid misdetection
	* Third, we will use a video odometry to determine how much the camera moves, then:
		* if the movement is lower that a certain threshold, we use video stablizer
		* if the movement is greater than the threshold, then we reset the algorithm to calculte again.
	* Fourth, we use a growing neural network to remove the outlier regions.
	*** Fifth, we use the connections of upper neurons in the gnn to visualize the movement of the region
		* If we can modify the algorithm in a way that find the gas flow and follow it through the frames then we have the movements.

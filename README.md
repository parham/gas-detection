
# Gas Leak Detection using Thermal Image Flow Analysis

In recent decades, thanks to the advancement of IR cameras, the use of this equipment for the non-destructive inspection of industrial sites has been growing increasingly for a variety of oil and gas applications, such as mechanical inspection, and the examination of pipe integrity. Recently, there is a rising interest in the application of gas imaging in various industries. Gas imaging can significantly enhance functional safety by early detection of hazardous gas leaks. Moreover, based on current efforts to decrease greenhouse gas emissions all around the world by using new technologies such as Optical Gas Imaging (OGI) to identify possible gas leakages regularly, the need for techniques to automate the inspection process can be essential. One of the main challenges in gas imaging is the proximity condition required for data to be more reliable for analysis. Therefore, the use of unmanned aerial vehicles can be very advantageous as they can provide significant access due to their maneuver capabilities. Despite the advantages of using drones, their movements, and sudden motions during hovering can diminish data usability. In this paper, we investigate the employment of drones in gas imaging applications. Also, we present a novel approach to enhance the visibility of gas leaks in aerial thermal footages using image flow analysis. Moreover, we investigate the use of the phase correlation technique for the reduction of drone movements during hovering. The significance of the results presented in this paper demonstrates the possible use of this approach in the industry.

## Future Changes for V2.0:

* We will use a floating-window to process the frames incrementally.
* We will use a regression model to follow the window in order to avoid misdetection
* We will use a video odometry to determine how much the camera moves, then:
	** if the movement is lower that a certain threshold, we use video stablizer
	** if the movement is greater than the threshold, then we reset the algorithm to calculte again.
* We use a growing neural network to remove the outlier regions.
* We use the connections of upper neurons in the gnn to visualize the movement of the region
	* If we can modify the algorithm in a way that find the gas flow and follow it through the frames then we have the movements.

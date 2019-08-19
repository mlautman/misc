# ROS Notes

## Test Communication

Server

    rostopic pub /test std_msgs/Bool true -r 10

Client

    rostopic echo /test

## Convert URDF to PDF

    urdf_to_graphiz

# View TF as PDF

    tfpdf

## Kill all ROS nodes

    killall rosout
    killall rosout -9

# Eigen Library Notes

## Output translation

    Eigen::Affine3d tmp;
    std::cout << "Position: " << tmp.translation() << std::endl;

## Create an empty transform

    Eigen::Affine3d offset = Eigen::Affine3d::Identity();

## Change the location of a transformation

    offset.translation().y() = 0;

## Apply an offset to an existing pose

    pose = offset * pose;

## Create pose with values

    Eigen::Affine3d pose = Eigen::Translation3d(x, y, z) *
      Eigen::Quaterniond(rw, rx, ry, rz);

## Rotate certain axis

    Eigen::Affine3d pose;
    pose = Eigen::AngleAxisd(theta1, Eigen::Vector3d::UnitX())
    * Eigen::AngleAxisd(-0.5*M_PI, Eigen::Vector3d::UnitZ())
    * Eigen::AngleAxisd(theta2, Eigen::Vector3d::UnitX()); // Flip 'direction'

    pose.translation() = Eigen::Vector3d( yb, xb ,zb);

## Rotate certain axis simple

    double theta = M_PI / 2.0;
    Eigen::Affine3d pose = ...;
    pose = pose * Eigen::AngleAxisd(theta, Eigen::Vector3d::UnitX());

## Create an Affine 3D

    void poseMsgToEigen(const geometry_msgs::Pose &m, Eigen::Affine3d &e)
    e = Eigen::Translation3d(m.position.x,
                           m.position.y,
                           m.position.z) *
    Eigen::Quaterniond(m.orientation.w,
                       m.orientation.x,
                       m.orientation.y,
                       m.orientation.z);

## Move an eigen pose in a direction a certain distance relative to the pose itself

    Eigen::Affine3d start_pose = getCurrentState()->getGlobalLinkTransform(grasp_datas_[arm_jmg]->parent_link_);
    Eigen::Affine3d target_pose = start_pose;

    double theta = 3.14; // some rotation in radians
    const double desired_distance = 0.005;
    Eigen::Vector3d direction;
    direction << -1 * sin(theta), 0, cos(theta);

    const Eigen::Vector3d rotated_direction = start_pose.rotation() * direction;
    target_pose.translation() += rotated_direction * desired_distance;

## Get the pose between two points

    See rviz_visual_tools/getVectorBetweenPoints()

## Get distance between two points

    Eigen::Vector3d a, b;
    double distance = (a - b).lpNorm<2>();

## Convert from left to right hand coordiante systems

    Vector3 ros_position = new Vector3(
           transform.pos.z,
	  -1 * transform.pos.x,
           transform.pos.y);
	Quaternion ros_orientation = new Quaternion(
	  -1 * transform.rot.z,
	       transform.rot.x,
	  -1 * transform.rot.y,
           transform.rot.w);

## Distance between two quaternions

```
  double getPoseDistance(const Eigen::Affine3d &from_pose, const Eigen::Affine3d &to_pose)
  {
    std::cout << std::endl;

    const double translation_dist = (from_pose.translation() - to_pose.translation()).norm();

    const double distance_wrist_to_finger = 0.25; // meter

    const Eigen::Quaterniond from(from_pose.rotation());
    const Eigen::Quaterniond to(to_pose.rotation());

    std::cout << "From: " << from.x() << ", " << from.y() << ", " << from.z() << ", " << from.w() << std::endl;
    std::cout << "To: " << to.x() << ", " << to.y() << ", " << to.z() << ", " << to.w() << std::endl;

    double rotational_dist = arcLength(from, to) * distance_wrist_to_finger;

    std::cout << "  Translation_Dist: " << std::fixed << std::setprecision(4) << translation_dist
              << " rotational_dist: " << rotational_dist << std::endl;

    return rotational_dist + translation_dist;
  }

  double arcLength(const Eigen::Quaterniond &from, const Eigen::Quaterniond &to)
  {
    static const double MAX_QUATERNION_NORM_ERROR = 1e-9;
    double dq = fabs(from.x() * to.x() + from.y() * to.y() + from.z() * to.z() + from.w() * to.w());
    if (dq > 1.0 - MAX_QUATERNION_NORM_ERROR)
      return 0.0;
    else
      return acos(dq) * 2.0; // DTC i added the x2 because it makes opposite angles pi distance
  }
```

## Get Euler Angles from Quaternion

      Eigen::Vector3d rpy = pose.rotation().eulerAngles(0, 1, 2);
      double rx = rpy(0);
      double ry = rpy(1);
      double rz = rpy(2);

## Get Quaternion from Pose

    Eigen::Quaterniond quat(pose.rotation());

## Linear Algebra
See http://eigen.tuxfamily.org/dox/classEigen_1_1MatrixBase.html#a8c247d700df304eb9a560bab60335ee1

### Cross Product

      Eigen::Vector3d y_axis = ...
      Eigen::Vector3d x_axis = y_axis.cross(z_axis);

### Dot Product

      Eigen::Vector3d uid_diff = ...
      double uid_diff_on_z = uid_diff.dot(kUnitVectorZUp);

### Transpose

      base_frame.rotation() = rotation.transpose();

### Normalize

      RotMatrix3x3 rotation(x_axis.normalized(), y_axis.normalized(), z_axis.normalized());

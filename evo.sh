#!/bin/bash
source ~/anaconda3/bin/activate evo_tool 

# Check if the correct number of arguments are provided
if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <bag_file> <output_folder_name> <yaml_file>"
  exit 1
fi

bag_file=$1
output_folder_name=$2
yaml_file=$3


cd ~/lab_localization/bag

if [ ! -f ${bag_file} ]; then
  echo "Can't find bag file: $bag_file"
  exit 1
fi

# output dir
parent_output_folder="/home/mingzhun/lab_localization/evo_result"
output_folder="$parent_output_folder/$output_folder_name"

# Check if the output folder already exists, prompt for overwrite if it does
if [ -d "$output_folder" ]; then
    read -p "The folder already exists. Do you want to overwrite it? (y/n): " choice
    if [ "$choice" == "y" ]; then
        echo "Overwriting folder: $output_folder"
        rm -rf "$output_folder"
        mkdir -p "$output_folder/plot" "$output_folder/trans_result" "$output_folder/rot_result"
    else
        echo "Using existing folder: ${output_folder}"
    fi
else
    # Create the output folder and subfolders if it doesn't exist
    mkdir -p "$output_folder/plot" "$output_folder/trans_result" "$output_folder/rot_result"
fi

# Run the evo_traj command and save the plot 
evo_traj bag $bag_file /amcl_pose /PLICP_pose --ref /base_gt -v -p --plot_mode xy --save_plot "$output_folder/plot/" --ros_map_yaml "$yaml_file"
echo "evo_traj command executed successfully. Results saved in: $output_folder"

# Run the evo_ape command for amcl_pose translation and rotation APE
evo_ape bag $bag_file /base_gt /amcl_pose -v -p --plot_mode xy --save_plot "$output_folder/plot/amcl_trans" --ros_map_yaml "$yaml_file" --save_result "$output_folder/trans_result/amcl_trans.zip"
evo_ape bag $bag_file /base_gt /amcl_pose -v -p --plot_mode xy --save_plot "$output_folder/plot/amcl_rot" --ros_map_yaml "$yaml_file" --save_result "$output_folder/rot_result/amcl_rot.zip" -r angle_deg

# Run the evo_ape command for PLICP_pose translation and rotation APE
evo_ape bag $bag_file /base_gt /PLICP_pose -v -p --plot_mode xy --save_plot "$output_folder/plot/PLICP_trans" --ros_map_yaml "$yaml_file" --save_result "$output_folder/trans_result/PLICP_trans.zip"
evo_ape bag $bag_file /base_gt /PLICP_pose -v -p --plot_mode xy --save_plot "$output_folder/plot/PLICP_rot" --ros_map_yaml "$yaml_file" --save_result "$output_folder/rot_result/PLICP_rot.zip" -r angle_deg
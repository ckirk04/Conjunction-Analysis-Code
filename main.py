import os
import streamlit as st
import pandas as pd
import numpy as np
from tabulate import tabulate
import time
import webbrowser
start_time = time.time()
#here is the only input for this script: the location where we want to search
input_from_user = 'C:/Users/alexa/OneDrive/Desktop/Shared Code/100'





def count_files_in_folder(folder_path):
    try:
        file_count = len([f for f in os.listdir(folder_path) if os.path.isfile(os.path.join(folder_path, f))])
        return file_count
    except FileNotFoundError:
        return -1  # Folder not found
    except Exception as e:
        print(e)
        return -2  # Other error

def input_files_in_folder(folder_path):
    try: 
        files = os.listdir(folder_path)
        input_files_in_folder = [f for f in files if os.path.isfile(os.path.join(folder_path, f)) and f.startswith("Sat") and f.endswith(".txt")]
        return input_files_in_folder
    except FileNotFoundError:
        return None  # Folder not found
    except Exception as e:
        print(e)
        return None  # Other error    
         
folder_path = input_from_user

file_count = count_files_in_folder(folder_path)
input_files_in_folder=input_files_in_folder(input_from_user)
number_of_input_satellites = len(input_files_in_folder)


try: 
    if file_count == -1:
        print("Folder not found.")
    elif file_count == -2:
        print("An error occurred while counting files.")
    else:
        print(f"There are {file_count} files in the folder, and there are There are {number_of_input_satellites} input satellite files in the folder.")
except:
    print("Error. There's something wrong with your input folder.")
    
##################################################################################
def read_txt_files_to_dataframes(folder_path):
    try:
        files = os.listdir(folder_path)
        txt_files = [f for f in files if os.path.isfile(os.path.join(folder_path, f)) and f.startswith("Sat") and f.endswith(".txt")]
        
        dataframes = []
        
        for txt_file in txt_files:
            file_path = os.path.join(folder_path, txt_file)
            df = pd.read_csv(file_path, delim_whitespace=True, header=None, names=['x', 'y', 'z'])  # You can adjust the delimiter as needed
            
            if df.shape[1]<4:
                dataframes.append(df)
                
        return dataframes
    except FileNotFoundError:
        return None  # Folder not found
    except Exception as e:
        return None  # Other error


#generate a series of dataframes from each input file
txt_dataframes = read_txt_files_to_dataframes(folder_path)
#check the sizing across all files:
shortest_length_of_time = min(len(df) for df in txt_dataframes)


#######################################################################################

#print(txt_dataframes)

#conjunctions is a vector with Sat1, Sat2, time i, and distance as its shape
conjunctions = []

    
for j in range(0,number_of_input_satellites):
    
    for k in range(j+1, number_of_input_satellites):
        
        
        
            delta_df = txt_dataframes[j]-txt_dataframes[k]      
            

            
            

            # Calculate the norm of the difference vector
            delta_df['2-norm'] = np.linalg.norm(delta_df.values, axis=1)
            
            # Number to compare against
            threshold = 5
            
            condition = delta_df['2-norm'] < threshold
            
            indices_with_less_values = delta_df[condition].index.tolist()
            values_with_less_threshold = delta_df[condition]['2-norm'].tolist()
            #print(indices_with_less_values)
            #print(values_with_less_threshold)
            if indices_with_less_values:
                conjunctions.append([j,k,indices_with_less_values,values_with_less_threshold])
            else:
                continue
                
#################################################################################
end_time = time.time()
elapsed_time = end_time - start_time   
#print(f"Elapsed time: {elapsed_time:.4f} seconds")

if conjunctions:
    conjunctions_vector=[]
    headers= ["First Satellite" , "Second Satellite", "Time index of the Conjunction", "Distance between Satellites"]
    
    
    for item in conjunctions:
        first_element = item[0]
        second_element = item[1]

        for third_element, fourth_element in zip(item[2], item[3]):
            #print(f"{input_files_in_folder[first_element]}, {input_files_in_folder[second_element]}, {third_element}, {fourth_element}")
            conjunctions_vector.append((input_files_in_folder[first_element],input_files_in_folder[second_element], third_element, fourth_element))
    #print(conjunctions_vector)
    table_html = tabulate(conjunctions_vector, headers=headers, tablefmt='html')
    #print(table_html)
    
    # Prepare the ASCII art of a satellite
    satellite_ascii_art = r"""
                __
       .-"'  "" "" "-.
    .-'               '-.
   |     .-' .-. '-.     |
   |    |   |_|_|   |    |
   |     '-.     .-'     |
    '-.    ""---""    .-'
      '-.           .-'
         ""--...--""
"""
    

    table_rows_count = table_html.count('<tr>')
    # Combine the table and satellite image in an HTML file
    html_content = f"""
<!DOCTYPE html>
<html>
<head>
    <title>Conjunction Data - {number_of_input_satellites} Satellites</title>
    <link rel="icon" href="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTd6GgLOH1KUNCzbe-YDHNoVlxCFnfnoJN-QQ&s" type="image/x-icon">
    <style>
        body {{ font-family: Arial, sans-serif; }}
        table {{ border-collapse: collapse; width: 80%; margin: 0 auto; }}
        th, td {{ border: 1px solid black; padding: 8px; text-align: left; }}
    </style>
</head>
<body>
    <div style="display: flex; justify-content: space-between;">
        <div><img src="html_logo_esl.png" alt="ESL Logo" ></div>
        
    </div>
    <h1 style="text-align: center;">Conjunction Data</h1>
    <p style="text-align: center; font-weight: bold;">
        This code found {table_rows_count} conjunction events over the course of the analysis.
    </p>
    <p style="text-align: center; font-weight: bold;">
        This table was built using Python and position files from {number_of_input_satellites} satellites from GMAT.
    </p>
    {table_html}
    <p style="text-align: center; font-weight: bold;">
        This code took '{elapsed_time:.4f} seconds' to run.
    </p>
    <p style="text-align: center;">:</p>
    <img src="https://gmat.sourceforge.net/docs/R2020a/files/images/Intro_GettingStarted_WindowsGUI.png" alt="Satellite Image" style="display: block; margin: 0 auto;">
    <div><img src="mit.png" alt="MIT Logo" ></div>
</body>
</html>
"""

# Write the HTML content to a file
    html_file_name = f'conjunction_data_{number_of_input_satellites}_satellites_{start_time}.html'
    with open(html_file_name, 'w') as f:
        f.write(html_content)

# Write the HTML content to a file
    html_file_name = f'conjunction_data_{number_of_input_satellites}_satellites_{start_time}.html'
    with open(html_file_name, 'w') as f:
        f.write(html_content)
    webbrowser.open(f"{html_file_name}")
else:
    print("The list of conjunctions is empty.")
    
    


            

            




    
    
    
    
    
# -*- coding: utf-8 -*-
"""
Created on Mon May 27 16:56:06 2024

@author: Campbell
"""

import os
import sys

from pathlib import Path

import numpy as np
import pandas as pd

from natsort import natsorted

import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec

def return_fit():
    """ returns a single value definining the least squares fit
        between the current simulation and the target data """
        
    # Variables
    top_data_folder = '../sim_data/sim_output'
    target_forces_file = '../target_data/target_forces.txt'
    trial_errors_file = '../working/trial_errors.xlsx'
    sim_comparison_file = 'sim_comparison_current.png'
    
    # Code
    # Adapt because files are relative to this file
    parent_dir = Path(__file__).parent.absolute()
    top_data_folder = Path(os.path.join(parent_dir, top_data_folder)).resolve()
    
    target_forces_file = Path(os.path.join(parent_dir, target_forces_file)).resolve()

    trial_errors_file = os.path.join(parent_dir, trial_errors_file)
    
    sim_comparison_file = os.path.join(top_data_folder, sim_comparison_file)
    

    # Load the target forces
    target_forces = np.genfromtxt(target_forces_file, delimiter='\t')
    
    # Find the simulation files
    cond_counter = 1
    keep_going = True
    
    sim_folder = os.path.join(top_data_folder, '1')        

    # Find the results files
    sim_files = os.listdir(sim_folder)
    sim_files = natsorted(sim_files)
    
    # Set up for error components
    error_components = []
    
    # Make a 2 panel figure
    no_of_rows = 2
    no_of_cols = 1
    
    fig = plt.figure(constrained_layout = False)
    spec = gridspec.GridSpec(nrows = no_of_rows,
                             ncols = no_of_cols,
                             figure = fig,
                             wspace = 1,
                             hspace = 1)
    fig.set_size_inches([5, 7])
    
    ax = []
    for i in range(no_of_rows):
        for j in range(no_of_cols):
            ax.append(fig.add_subplot(spec[i,j]))
            
    # Now loop through files
    
    for file in sim_files:
        if file.endswith('.txt'):
            
            # Load up the simulation
            sim_file_string = os.path.join(sim_folder, file)
            d = pd.read_csv(sim_file_string, delimiter = '\t')

            # Pull off simulated force            
            sim_f = d.m_force.to_numpy()
            sim_points = len(sim_f)

            # Pull out target force
            target_f = target_forces[:, cond_counter-1]
            target_points = len(target_f)
            
            # Prune to the target points
            comp_f = sim_f[-target_points::]
            comp_points = len(comp_f)
            
            # Calculate least squares
            rel_diff = (comp_f - target_f) / target_f
    
            ec = np.sum(np.power(rel_diff, 2))
            
            error_components.append(ec)
            
            # Plot data
            ti = np.arange(sim_points - target_points, sim_points)
            ax[0].plot(d.time[ti], target_f, 'k-')
            ax[0].plot(d.time, d.m_force, 'b-')
            
            ax[1].plot(d.time, d.m_length, 'b-')
            
            # Update counter                    
            cond_counter = cond_counter + 1
        else:
            keep_going = False
            
    # Save figure
    fig.savefig(sim_comparison_file,
                bbox_inches='tight',
                dpi=200)
    
            
    # Calculate the final error value
    e = np.sum(error_components)

    # Write error data to file
    d = dict()
    for i in range(len(error_components)):
        d['error_cpt_%i' % (i+1)] = error_components[i]
    d['error_total'] = e
     
    # Make a dataframe    
    df = pd.DataFrame(data=d, index=[0])
     
    # Check the dir exists
    worker_parent_dir = Path(trial_errors_file).parent
    if not os.path.isdir(worker_parent_dir):
        os.makedirs(worker_parent_dir)
     
    # Clean the file and then write
    if (os.path.exists(trial_errors_file)):
        os.remove(trial_errors_file)
    df.to_excel(trial_errors_file, index=False)
        
if __name__ == "__main__":
    return_fit()                    
                    
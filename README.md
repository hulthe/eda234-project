<!-- GETTING STARTED -->
## Getting Started

To get a local copy up and running follow these simple steps.

### Prerequisites

Vivado version 2020.2 is advised for synthesis and implementation as some of the IP blocks used in this project may change in newer versions of Vivado.


### Project Installation

1. Clone the repo
   ```sh
   git clone https://github.com/hulthe/eda234-project/
   ```
2. Open Vivado and move into project directory
   ```sh
   cd eda234-project/
   ```
3. Generate the project using the .tcl script
    ```sh
    source ./git_project.tcl
    ```
		
### Updating the project

1. Make sure you are in the root folder using 			
   ```sh
   pwd
   ```

2. Update the .tcl script
   ```sh
   write_project_tcl -force git_project.tcl
   ```

FROM public.ecr.aws/d3j8x8q7/olympus-base-python:latest

WORKDIR /app

ENV PYVISTA_OFF_SCREEN=TRUE

# Install system dependencies for OpenGL/VTK and XVFB
RUN apt-get update && apt-get install -y \
        libgl1 \
        libglvnd0 \
        libglx0 \
        libx11-6 \
        libxext6 \
        libglib2.0-0 \
        xvfb \
        && rm -rf /var/lib/apt/lists/*

# Copy the entire repository contents into the container
COPY . .

# Install dependencies required to run the PyNite tests
RUN pip install --no-cache-dir \
        numpy==2.5.3 \
        scipy==1.18.1 \
        pyparsing==3.3.3 \
        pytest==9.1.1 \
        pillow==12.3.0 \
        PyYAML==6.0.3 \
        matplotlib==3.11.2 \
        prettytable==3.10.0 \
        ipython==8.22.0 \
        vtk==9.3.0 \
        pyvista==0.43.5 \
        trame-vtk==2.11.17 \
        ipywidgets==8.1.2 \
        PyniteFEA[all]

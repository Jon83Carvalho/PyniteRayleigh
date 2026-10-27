FROM public.ecr.aws/d3j8x8q7/olympus-base-python:latest

WORKDIR /app

# Copy the entire repository contents into the container
COPY . .

# Install dependencies required to run the PyNite tests
# We explicitly install pytest to support the JUnit XML output in test.sh
RUN pip install --no-cache-dir \
        numpy==2.5.3 \
        scipy==1.18.1 \
        pyparsing==3.3.3 \
        pytest==9.1.1 \
        pillow==12.3.0 \
        PyYAML==6.0.3 \
        matplotlib==3.11.2 \
        prettytable==3.10.0

# Default to bash as requested in the base guide
CMD ["/bin/bash"]

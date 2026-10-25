FROM public.ecr.aws/d3j8x8q7/olympus-base-python:latest

WORKDIR /app

# Copy the entire repository contents into the container
COPY . .

# Install dependencies required to run the PyNite tests
# We explicitly install pytest to support the JUnit XML output in test.sh
RUN pip install -r requirements.txt 

# Default to bash as requested in the base guide
CMD ["/bin/bash"]

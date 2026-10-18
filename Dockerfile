FROM public.ecr.aws/d3j8x8q7/olympus-base-python:latest

WORKDIR /app

# Copy the entire repository contents into the container
COPY . .

# Install dependencies required to run the PyNite tests
# We install pytest specifically to support the JUnit XML output in test.sh
RUN pip install --no-cache-dir \
    numpy \
    scipy \
    PyniteFEA[all]

# Ensure the test harness is executable
# Default to bash as requested in the base guide
CMD ["/bin/bash"]

#!/bin/sh
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 817831614729.dkr.ecr.us-east-1.amazonaws.com
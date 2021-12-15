#!/bin/bash

exo compute sks kubeconfig webcluster admin -z de-fra-1 > kubeconfig
chmod o-rwx kubeconfig
chmod g-rwx kubeconfig
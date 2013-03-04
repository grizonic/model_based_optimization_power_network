The purpose of this repo is mainly to host this code which is part of my graduation report. Therefore, it will probably be quite incomplete for those trying to understand the point behind it. If you're interested in oil-impregnated insulation, power transformers, decentralized control... feel free to contact me.

# Framework of Model-Based Optimization applied to the Electrical Power Network

The advanced ageing of the electrical power network combined with the inevitable increase
of renewable energy utilization and the constant increase of power consumption over the last
decades call for a change in the current power network paradigm. Electrical world stakeholders
have to embrace the situation and come up with methods of better utilizing the existing, but
also new, network resources. The ongoing financial crisis also behaves as an eye opener for new
concepts and smart opportunities.

This project’s approach is to create a modern and automated layer on top of the existing
power network physical layer which makes use of several physical models to interpret the current
and future expected health status of the network’s components. With this automated layer, the
network operator can configure the network to be a self-sustainable, or at least more independent,
and a more insightful system. Real-time and projections of the network’s health status can be
used as power flow optimization factors.

Simulations based on real power flow data have shown that distributing thermal loading
throughout neighbouring power components results in a more efficient resource utilization as it
lowers the overall network accelerated ageing factor, while keeping the power flow characteristics
within the legislated integrity limits.

It has been shown that, by applying this health prediction framework to the IEEE-14 bus
network and allowing the layer to act in a decentralized fashion independently of the network
operator, the overall network lifetime utilization can be reduced by 80% by rerouteing only
13% of the overall power flow. This rerouteing of power flow does not compromise the load
requirements, nor it uses more power components than the ones present in the IEEE-14 bus
network configuration.

Although it is difficult to implement this framework layer on top of the electrical power net-
work, due to its well-known structural inertia, it has been shown that this system can effectively
be deployed in different steps in time. Furthermore, the level of trust the network operator has
in the system can also be incrementally upgraded, as this layer can be used at first simply as a
more insightful source of data and only when desired it can be used as a more active factor in
the electrical power network management.

# Contents

## Tettex 2840 Script:
A simple python script that translates the raw xml outputted by the Tettex 2840 and produces quite costomizable csv files.

## Single Agent Optimization:
With an ugly Matlab GUI created in GUIDE and using real power flow data, you can variate several inputs to analyse the behaviour of a single agent built on top of a power transformer;

## IEEE 14 network simulation:
Agents are placed on all three transformers of the network. The network is transformed into a self-sustainable mesh that tries to distribute thermal loading throughout the less loaded nodes in order to avoid the steep lifetime consumption of highly thermally loaded transformers.


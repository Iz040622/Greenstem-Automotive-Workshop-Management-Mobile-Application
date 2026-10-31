import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:mad_assignment/widgets/gradient_scaffold.dart';
import '../services/user_storage_service.dart';

class FeedbackPage extends StatefulWidget {
  final bool isViewMode;
  final String? bookingId; // Add booking ID to associate feedback with specific booking
  
  const FeedbackPage({super.key, this.isViewMode = false, this.bookingId});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  int? selectedRating; // 1-5
  Set<String> selectedOptions = {};
  final TextEditingController commentController = TextEditingController();
  bool _isSubmitting = false;
  bool _isLoading = false;
  Map<String, dynamic>? _existingFeedback;

  final List<Map<String, dynamic>> ratingIcons = [
    {"value": 1, "icon": Icons.sentiment_very_dissatisfied, "label": "Very Dissatisfied"},
    {"value": 2, "icon": Icons.sentiment_dissatisfied, "label": "Dissatisfied"},
    {"value": 3, "icon": Icons.sentiment_neutral, "label": "Neutral"},
    {"value": 4, "icon": Icons.sentiment_satisfied, "label": "Satisfied"},
    {"value": 5, "icon": Icons.sentiment_very_satisfied, "label": "Very Satisfied"},
  ];

  final List<String> options = [
    "Affordable Price",
    "Friendly Staff",
    "Professional Technicians",
    "Fast Service"
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isViewMode) {
      _loadExistingFeedback();
    }
  }

  Future<void> _loadExistingFeedback() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = await UserStorageService.getUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final database = FirebaseDatabase.instance;
      final feedbackRef = database.ref('Feedback');
      final snapshot = await feedbackRef.get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        
        // Find the most recent feedback from this user
        Map<String, dynamic>? latestFeedback;
        int latestTimestamp = 0;

        data.forEach((key, value) {
          final feedback = Map<String, dynamic>.from(value);
          if (feedback['userId'] == userId && feedback['bookingId'] == widget.bookingId) {
            final timestamp = feedback['timestamp'] ?? 0;
            if (timestamp > latestTimestamp) {
              latestTimestamp = timestamp;
              latestFeedback = feedback;
            }
          }
        });

        if (latestFeedback != null && mounted) {
          setState(() {
            _existingFeedback = latestFeedback;
            selectedRating = latestFeedback!['rating'];
            selectedOptions = Set<String>.from(latestFeedback!['selectedOptions'] ?? []);
            commentController.text = latestFeedback!['comment'] ?? '';
            _isLoading = false;
          });
        } else {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to load feedback: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> submitFeedback() async {
    if (selectedRating == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a rating"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Get current user ID
      final userId = await UserStorageService.getUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Create feedback data
      final feedbackData = {
        'userId': userId,
        'bookingId': widget.bookingId, // Associate feedback with specific booking
        'rating': selectedRating,
        'selectedOptions': selectedOptions.toList(),
        'comment': commentController.text.trim(),
        'submissionDate': DateFormat("d/M/y").format(DateTime.now()),
        'submissionTime': DateFormat("h:mma").format(DateTime.now()),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      // Store in Firebase
      final database = FirebaseDatabase.instance;
      final feedbackRef = database.ref('Feedback');
      await feedbackRef.push().set(feedbackData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Thank you for your feedback!"),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to booking list page
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to submit feedback: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: GradientScaffold.dynamicAppBar(
        context: context,
        widget: Text(widget.isViewMode ? "View Feedback" : "Feedback"),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Feedback Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Colors.purple.shade50,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(2, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Main Title
                  const Text(
                    "Share your feedback!",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Satisfaction Question
                  const Text(
                    "How satisfied are you with today's experience?",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Rating Icons
                  Row(
                    children: ratingIcons.map((item) {
                      return Expanded(
                        child: GestureDetector(
                          onTap: widget.isViewMode ? null : () {
                            setState(() {
                              selectedRating = item["value"];
                            });
                          },
                          child: Column(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: selectedRating == item["value"]
                                      ? Colors.blue.shade100
                                      : Colors.grey.shade100,
                                  border: Border.all(
                                    color: selectedRating == item["value"]
                                        ? Colors.blue
                                        : Colors.grey.shade300,
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  item["icon"],
                                  size: 30,
                                  color: selectedRating == item["value"]
                                      ? Colors.blue
                                      : Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                item["label"],
                                style: TextStyle(
                                  fontSize: 8,
                                  color: selectedRating == item["value"]
                                      ? Colors.blue
                                      : Colors.grey.shade600,
                                  fontWeight: selectedRating == item["value"]
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Likes Question
                  const Text(
                    "What did you like the most?",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 15),
                  
                  // Options Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 2.5,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    children: options.map((option) {
                      return GestureDetector(
                        onTap: widget.isViewMode ? null : () {
                          setState(() {
                            if (selectedOptions.contains(option)) {
                              selectedOptions.remove(option);
                            } else {
                              selectedOptions.add(option);
                            }
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: selectedOptions.contains(option)
                                ? Colors.blue.shade100
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selectedOptions.contains(option)
                                  ? Colors.blue
                                  : Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              option,
                              style: TextStyle(
                                fontSize: 12,
                                color: selectedOptions.contains(option)
                                    ? Colors.blue
                                    : Colors.grey.shade700,
                                fontWeight: selectedOptions.contains(option)
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 25),
                  
                  // Comment Section
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Comment (optional)",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  TextField(
                    controller: commentController,
                    maxLines: 4,
                    readOnly: widget.isViewMode,
                    decoration: InputDecoration(
                      hintText: widget.isViewMode ? "" : "Tell us more about your experience...",
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.blue, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 12,
                      ),
                    ),
                    style: const TextStyle(color: Colors.black),
                  ),
                  
                  const SizedBox(height: 25),
                  
                  // Submit Button (only show in edit mode)
                  if (!widget.isViewMode)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : submitFeedback,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                        ),
                        child: _isSubmitting
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    "Submitting...",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              )
                            : const Text(
                                "Submit",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  
                  // Show feedback submission date in view mode
                  if (widget.isViewMode && _existingFeedback != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      margin: const EdgeInsets.only(top: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Feedback Submitted:",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "${_existingFeedback!['submissionDate']} at ${_existingFeedback!['submissionTime']}",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from datetime import datetime, timedelta
import re
import json
from collections import Counter, defaultdict
import nltk
from nltk.sentiment import SentimentIntensityAnalyzer
from nltk.tokenize import word_tokenize
from nltk.corpus import stopwords
from nltk.probability import FreqDist
import networkx as nx
from wordcloud import WordCloud

class WhatsAppPatternExtractor:
    """
    Advanced system for extracting communication patterns from WhatsApp data,
    focused on detecting changes over time and correlating with external events.
    """

    def __init__(self, medication_timeline = None):
        """
        Initialize the WhatsApp pattern extractor.

        Parameters:
        -----------
        medication_timeline : dict, optional
            Dictionary containing 'start_date' and 'end_date' for the medication period.
        """
        # Default medication timeline if not provided
        if medication_timeline is None:
            self.medication_timeline = {
                'start_date': datetime(2024, 3, 1),
                'end_date': datetime(2024, 11, 30)
            }
        else:
            self.medication_timeline = medication_timeline

        # Initialize NLTK components
        self.sentiment_analyzer = SentimentIntensityAnalyzer()

        # Define patterns to track
        self.patterns = {
            'affection': ['love', 'miss', 'bui', 'ams', 'bubu', 'bobo', 'amsy', '❤️', '😘', '❤', 'godi'],
            'care': ['khana', 'eat', 'food', 'reached', 'home', 'safe', 'sleep', 'rest', 'medicine', 'dinner'],
            'distance': ['space', 'leave', 'stop', "don't", 'alone', 'away', 'separate', 'cannot'],
            'irritation': ['why', 'always', 'never', 'enough', 'problem', 'issue'],
            'gold': ['gold', 'ornaments', 'jewellery', 'jewelry']
        }

        # Define key events
        self.key_events = []

        # Data containers
        self.data = None
        self.processed_data = None
        self.analysis_results = {}

    def load_data(self, file_path):
        """
        Load WhatsApp chat export data from CSV file.

        Parameters:
        -----------
        file_path : str
            Path to the CSV file
        """
        try:
            self.data = pd.read_csv(file_path)
            print(f"Loaded {len(self.data)} messages from {file_path}")
            return True
        except Exception as e:
            print(f"Error loading data: {e}")
            return False

    def add_key_event(self, date, description, event_type = None):
        """
        Add a key event to the timeline.

        Parameters:
        -----------
        date : str or datetime
            The date of the event
        description : str
            Description of the event
        event_type : str, optional
            Type of event (e.g., 'relationship', 'medical', etc.)
        """
        if isinstance(date, str):
            date = datetime.strptime(date, '%Y-%m-%d')

        self.key_events.append({
            'date': date,
            'description': description,
            'type': event_type
        })

        return len(self.key_events)

    def preprocess_data(self):
        """Preprocess WhatsApp data for analysis."""
        if self.data is None:
            print("No data loaded. Please call load_data() first.")
            return False

        # Create a copy of the data
        self.processed_data = self.data.copy()

        # Ensure datetime format
        if 'Date' in self.processed_data.columns:
            self.processed_data['DateTime'] = pd.to_datetime(self.processed_data['Date'])

        # Standardize sender names
        if 'From' in self.processed_data.columns:
            self.processed_data['Sender'] = self.processed_data['From'].apply(
                lambda x: 'Abhishek' if x in ['Abhishek', 'You'] else 'Amrita' if x in ['Amrita', 'Amu'] else 'Other'
            )

        # Add message length
        if 'Message' in self.processed_data.columns:
            self.processed_data['MessageLength'] = self.processed_data['Message'].apply(
                lambda x: len(str(x)) if pd.notna(x) else 0
            )

        # Add sentiment analysis
        if 'Message' in self.processed_data.columns:
            self.processed_data['Sentiment'] = self.processed_data['Message'].apply(
                lambda x: self.sentiment_analyzer.polarity_scores(str(x))['compound'] if pd.notna(x) else 0
            )

        # Add pattern detection columns
        for pattern_name, keywords in self.patterns.items():
            pattern_col = f'Contains{pattern_name.capitalize()}'
            self.processed_data[pattern_col] = self.processed_data['Message'].apply(
                lambda x: 1 if any(keyword in str(x).lower() for keyword in keywords) else 0
            )

        # Add medication period flag
        self.processed_data['MedicationPeriod'] = self.processed_data['DateTime'].apply(
            lambda x: 'Before' if x < self.medication_timeline['start_date']
                    else 'After' if x > self.medication_timeline['end_date']
                    else 'During'
        )

        # Calculate response times
        self.processed_data = self.processed_data.sort_values('DateTime')
        self.processed_data['PrevDateTime'] = self.processed_data['DateTime'].shift(1)
        self.processed_data['PrevSender'] = self.processed_data['Sender'].shift(1)

        # Calculate response time only for different senders
        self.processed_data['ResponseTimeMinutes'] = self.processed_data.apply(
            lambda row: (row['DateTime'] - row['PrevDateTime']).total_seconds() / 60
            if row['Sender'] != row['PrevSender'] else np.nan,
            axis = 1
        )

        print(f"Preprocessed {len(self.processed_data)} messages")
        return True

    def analyze_message_frequency(self, time_unit = 'M'):
        """
        Analyze message frequency over time by sender.

        Parameters:
        -----------
        time_unit : str
            Time unit for grouping ('D' for day, 'W' for week, 'M' for month)
        """
        if self.processed_data is None:
            print("No processed data available. Please call preprocess_data() first.")
            return None

        # Group by time unit and sender
        time_grouped = self.processed_data.groupby([
            pd.Grouper(key = 'DateTime', freq = time_unit), 'Sender'
        ]).size().unstack(fill_value = 0)

        self.analysis_results['message_frequency'] = time_grouped
        return time_grouped

    def analyze_pattern_frequency(self, time_unit = 'M'):
        """
        Analyze pattern frequencies over time.

        Parameters:
        -----------
        time_unit : str
            Time unit for grouping ('D' for day, 'W' for week, 'M' for month)
        """
        if self.processed_data is None:
            print("No processed data available. Please call preprocess_data() first.")
            return None

        # Get pattern columns
        pattern_columns = [col for col in self.processed_data.columns if col.startswith('Contains')]

        # Group by time
        pattern_time_series = {}
        for col in pattern_columns:
            pattern_time_series[col] = self.processed_data.groupby([
                pd.Grouper(key = 'DateTime', freq = time_unit)
            ])[col].mean()

        pattern_data = pd.DataFrame(pattern_time_series)

        self.analysis_results['pattern_frequency'] = pattern_data
        return pattern_data

    def analyze_sentiment_by_period(self):
        """Analyze sentiment before, during, and after medication period."""
        if self.processed_data is None:
            print("No processed data available. Please call preprocess_data() first.")
            return None

        # Group by period and sender
        sentiment_by_period = self.processed_data.groupby(['MedicationPeriod', 'Sender'])['Sentiment'].agg(
            ['mean', 'median', 'std', 'count']
        )

        self.analysis_results['sentiment_by_period'] = sentiment_by_period
        return sentiment_by_period

    def analyze_response_times(self, time_unit = 'M'):
        """
        Analyze response times over time.

        Parameters:
        -----------
        time_unit : str
            Time unit for grouping ('D' for day, 'W' for week, 'M' for month)
        """
        if self.processed_data is None:
            print("No processed data available. Please call preprocess_data() first.")
            return None

        # Filter only rows with valid response times
        response_data = self.processed_data.dropna(subset = ['ResponseTimeMinutes'])

        # Group by time and calculate median response time
        response_time_series = response_data.groupby([
            pd.Grouper(key = 'DateTime', freq = time_unit), 'Sender'
        ])['ResponseTimeMinutes'].median().unstack(fill_value = 0)

        self.analysis_results['response_times'] = response_time_series
        return response_time_series

    def extract_word_usage_trends(self, min_freq = 5, top_n = 100):
        """
        Extract word usage trends before, during, and after medication.

        Parameters:
        -----------
        min_freq : int
            Minimum frequency for a word to be included
        top_n : int
            Maximum number of top words to return
        """
        if self.processed_data is None:
            print("No processed data available. Please call preprocess_data() first.")
            return None

        stop_words = set(stopwords.words('english'))

        # Add some custom stop words
        custom_stops = {'u', 'r', 'ur', 'n', 'm', 'll', 've', 'd', 's', 't', 'o', 'y', 'na'}
        stop_words.update(custom_stops)

        # Process by period
        word_usage = {}

        for period in ['Before', 'During', 'After']:
            period_data = self.processed_data[self.processed_data['MedicationPeriod'] == period]

            # Process by sender
            for sender in ['Abhishek', 'Amrita']:
                sender_data = period_data[period_data['Sender'] == sender]

                # Join all messages
                text = ' '.join(sender_data['Message'].dropna().astype(str))

                # Tokenize
                tokens = word_tokenize(text.lower())

                # Remove stop words and short words
                filtered_tokens = [
                    token for token in tokens
                    if token not in stop_words and len(token) > 1 and token.isalpha()
                ]

                # Count frequencies
                counter = Counter(filtered_tokens)

                # Get top n words
                top_words = counter.most_common(top_n)

                # Filter by minimum frequency
                top_words = [(word, count) for word, count in top_words if count >= min_freq]

                # Store
                word_usage[f"{period}_{sender}"] = top_words

        self.analysis_results['word_usage_trends'] = word_usage
        return word_usage

    def analyze_pattern_change_correlation(self):
        """Analyze correlation between different communication patterns."""
        if self.processed_data is None:
            print("No processed data available. Please call preprocess_data() first.")
            return None

        # Get pattern columns
        pattern_columns = [col for col in self.processed_data.columns if col.startswith('Contains')]

        # Calculate correlation matrix
        pattern_correlation = self.processed_data[pattern_columns].corr()

        self.analysis_results['pattern_correlation'] = pattern_correlation
        return pattern_correlation

    def analyze_gold_issue_pattern(self):
        """Specifically analyze the gold issue pattern."""
        if self.processed_data is None:
            print("No processed data available. Please call preprocess_data() first.")
            return None

        # Filter messages containing gold references
        gold_pattern = self.patterns.get('gold', ['gold', 'ornaments', 'jewellery', 'jewelry'])

        gold_messages = self.processed_data[
            self.processed_data['Message'].str.contains('|'.join(gold_pattern),
                                                      case = False,
                                                      regex = True,
                                                      na = False)
        ]

        # Sort by date
        gold_messages = gold_messages.sort_values('DateTime')

        # Calculate basic stats
        gold_analysis = {
            'total_mentions': len(gold_messages),
            'first_mention': gold_messages['DateTime'].min().strftime('%Y-%m-%d') if not gold_messages.empty else None,
            'by_sender': gold_messages['Sender'].value_counts().to_dict(),
            'by_period': gold_messages['MedicationPeriod'].value_counts().to_dict(),
            'messages': gold_messages[['DateTime', 'Sender', 'Message']].to_dict('records') if not gold_messages.empty else []
        }

        self.analysis_results['gold_issue'] = gold_analysis
        return gold_analysis

    def analyze_2d_thinking_references(self):
        """Analyze references to '2D thinking' in messages."""
        if self.processed_data is None:
            print("No processed data available. Please call preprocess_data() first.")
            return None

        # Search patterns for 2D thinking
        td_patterns = ['2D', 'two dimensional', 'simplified thinking', 'dimaag ab', '2d', 'two-dimensional']

        td_messages = self.processed_data[
            self.processed_data['Message'].str.contains('|'.join(td_patterns),
                                                      case = False,
                                                      regex = True,
                                                      na = False)
        ]

        # Sort by date
        td_messages = td_messages.sort_values('DateTime')

        # Calculate basic stats
        td_analysis = {
            'total_mentions': len(td_messages),
            'first_mention': td_messages['DateTime'].min().strftime('%Y-%m-%d') if not td_messages.empty else None,
            'by_sender': td_messages['Sender'].value_counts().to_dict(),
            'by_period': td_messages['MedicationPeriod'].value_counts().to_dict(),
            'messages': td_messages[['DateTime', 'Sender', 'Message']].to_dict('records') if not td_messages.empty else []
        }

        self.analysis_results['2d_thinking'] = td_analysis
        return td_analysis

    def extract_communication_style_changes(self):
        """Extract communication style changes over time."""
        if self.processed_data is None:
            print("No processed data available. Please call preprocess_data() first.")
            return None

        # Analyze by month
        self.processed_data['YearMonth'] = self.processed_data['DateTime'].dt.strftime('%Y-%m')

        # Calculate style metrics by month and sender
        style_metrics = {}

        for sender in ['Abhishek', 'Amrita']:
            sender_data = self.processed_data[self.processed_data['Sender'] == sender]

            # Calculate metrics by month
            monthly_metrics = {}

            for month, month_data in sender_data.groupby('YearMonth'):
                # Basic metrics
                metrics = {
                    'message_count': len(month_data),
                    'avg_message_length': month_data['MessageLength'].mean(),
                    'avg_sentiment': month_data['Sentiment'].mean(),
                    'response_time_median': month_data['ResponseTimeMinutes'].median()
                }

                # Pattern frequencies
                for pattern in self.patterns:
                    pattern_col = f'Contains{pattern.capitalize()}'
                    if pattern_col in month_data.columns:
                        metrics[f'{pattern}_frequency'] = month_data[pattern_col].mean()

                monthly_metrics[month] = metrics

            style_metrics[sender] = monthly_metrics

        self.analysis_results['communication_style'] = style_metrics
        return style_metrics

    def analyze_medication_period_changes(self):
        """Analyze changes in communication patterns before, during, and after medication."""
        if self.processed_data is None:
            print("No processed data available. Please call preprocess_data() first.")
            return None

        # Group by medication period and sender
        period_analysis = {}

        for sender in ['Abhishek', 'Amrita']:
            sender_data = self.processed_data[self.processed_data['Sender'] == sender]

            # Calculate metrics by period
            period_metrics = {}

            for period, period_data in sender_data.groupby('MedicationPeriod'):
                # Basic metrics
                metrics = {
                    'message_count': len(period_data),
                    'messages_per_day': len(period_data) / max(1, (period_data['DateTime'].max() - period_data['DateTime'].min()).days),
                    'avg_message_length': period_data['MessageLength'].mean(),
                    'avg_sentiment': period_data['Sentiment'].mean(),
                    'response_time_median': period_data['ResponseTimeMinutes'].median(),
                    'total_days': (period_data['DateTime'].max() - period_data['DateTime'].min()).days
                }

                # Pattern frequencies
                for pattern in self.patterns:
                    pattern_col = f'Contains{pattern.capitalize()}'
                    if pattern_col in period_data.columns:
                        metrics[f'{pattern}_frequency'] = period_data[pattern_col].mean()

                period_metrics[period] = metrics

            period_analysis[sender] = period_metrics

        # Calculate percent changes between periods
        percent_changes = {}

        for sender, periods in period_analysis.items():
            sender_changes = {}

            # Before to During
            if 'Before' in periods and 'During' in periods:
                before_to_during = {}

                for metric in periods['Before']:
                    if metric in periods['During'] and periods['Before'][metric] != 0:
                        before_to_during[metric] = ((periods['During'][metric] - periods['Before'][metric]) /
                                                   periods['Before'][metric]) * 100

                sender_changes['Before_to_During'] = before_to_during

            # During to After
            if 'During' in periods and 'After' in periods:
                during_to_after = {}

                for metric in periods['During']:
                    if metric in periods['After'] and periods['During'][metric] != 0:
                        during_to_after[metric] = ((periods['After'][metric] - periods['During'][metric]) /
                                                  periods['During'][metric]) * 100

                sender_changes['During_to_After'] = during_to_after

            percent_changes[sender] = sender_changes

        medication_analysis = {
            'period_metrics': period_analysis,
            'percent_changes': percent_changes
        }

        self.analysis_results['medication_period_changes'] = medication_analysis
        return medication_analysis

    def generate_comprehensive_report(self):
        """Generate a comprehensive report of all analyses."""
        # Ensure all analyses are run
        self.analyze_message_frequency()
        self.analyze_pattern_frequency()
        self.analyze_sentiment_by_period()
        self.analyze_response_times()
        self.extract_word_usage_trends()
        self.analyze_pattern_change_correlation()
        self.analyze_gold_issue_pattern()
        self.analyze_2d_thinking_references()
        self.extract_communication_style_changes()
        self.analyze_medication_period_changes()

        # Compile report
        report = {
            "data_summary": {
                "total_messages": len(self.processed_data),
                "date_range": [
                    self.processed_data['DateTime'].min().strftime('%Y-%m-%d'),
                    self.processed_data['DateTime'].max().strftime('%Y-%m-%d')
                ],
                "by_sender": self.processed_data['Sender'].value_counts().to_dict(),
                "by_medication_period": self.processed_data['MedicationPeriod'].value_counts().to_dict()
            },
            "key_findings": {
                "gold_issue": {
                    "total_mentions": self.analysis_results['gold_issue']['total_mentions'] if 'gold_issue' in self.analysis_results else 0,
                    "first_mention": self.analysis_results['gold_issue']['first_mention'] if 'gold_issue' in self.analysis_results else None
                },
                "2d_thinking": {
                    "total_mentions": self.analysis_results['2d_thinking']['total_mentions'] if '2d_thinking' in self.analysis_results else 0,
                    "first_mention": self.analysis_results['2d_thinking']['first_mention'] if '2d_thinking' in self.analysis_results else None
                }
            },
            "medication_period_insights": self.analysis_results['medication_period_changes'] if 'medication_period_changes' in self.analysis_results else {}
        }

        # Add most significant pattern changes
        if 'medication_period_changes' in self.analysis_results:
            amrita_changes = self.analysis_results['medication_period_changes']['percent_changes'].get('Amrita', {})

            if 'Before_to_During' in amrita_changes:
                # Get non-count metrics
                pattern_changes = {k: v for k, v in amrita_changes['Before_to_During'].items()
                                  if 'frequency' in k and not np.isnan(v) and not np.isinf(v)}

                if pattern_changes:
                    # Sort by absolute magnitude
                    sorted_changes = sorted(pattern_changes.items(), key = lambda x: abs(x[1]), reverse = True)

                    report['key_findings']['most_significant_pattern_changes'] = [
                        {"pattern": pattern.replace('_frequency', ''), "percent_change": change}
                        for pattern, change in sorted_changes[:3]
                    ]

        return report

    def plot_message_frequency(self, time_unit = 'M', save_path = None):
        """
        Plot message frequency over time.

        Parameters:
        -----------
        time_unit : str
            Time unit for grouping ('D' for day, 'W' for week, 'M' for month)
        save_path : str, optional
            Path to save the plot
        """
        if 'message_frequency' not in self.analysis_results:
            self.analyze_message_frequency(time_unit)

        if 'message_frequency' not in self.analysis_results:
            print("Could not analyze message frequency.")
            return None

        time_grouped = self.analysis_results['message_frequency']

        plt.figure(figsize=(14, 7))
        time_grouped.plot(kind = 'bar', stacked = True)

        # Add medication period
        plt.axvspan(
            self.medication_timeline['start_date'],
            self.medication_timeline['end_date'],
            alpha = 0.2, color = 'gray', label = 'Medication Period'
        )

        # Add key events
        for event in self.key_events:
            plt.axvline(x = event['date'], color = 'r', linestyle = '--', alpha = 0.3)
            plt.text(
                event['date'],
                time_grouped.max().max(),
                event['description'],
                rotation = 90,
                alpha = 0.7,
                fontsize = 8
            )

        plt.title('Message Frequency Over Time')
        plt.xlabel('Date')
        plt.ylabel('Number of Messages')
        plt.legend(title = 'Sender')
        plt.tight_layout()

        if save_path:
            plt.savefig(save_path)

        return plt

    def plot_pattern_evolution(self, time_unit = 'M', save_path = None):
        """
        Plot pattern evolution over time.

        Parameters:
        -----------
        time_unit : str
            Time unit for grouping ('D' for day, 'W' for week, 'M' for month)
        save_path : str, optional
            Path to save the plot
        """
        if 'pattern_frequency' not in self.analysis_results:
            self.analyze_pattern_frequency(time_unit)

        if 'pattern_frequency' not in self.analysis_results:
            print("Could not analyze pattern frequency.")
            return None

        pattern_data = self.analysis_results['pattern_frequency']

        # Clean column names for the legend
        pattern_data.columns = [col.replace('Contains', '') for col in pattern_data.columns]

        plt.figure(figsize=(14, 7))
        pattern_data.plot(kind = 'line', marker = 'o')

        # Add medication period
        plt.axvspan(
            self.medication_timeline['start_date'],
            self.medication_timeline['end_date'],
            alpha = 0.2, color = 'gray', label = 'Medication Period'
        )

        # Add key events
        for event in self.key_events:
            plt.axvline(x = event['date'], color = 'r', linestyle = '--', alpha = 0.3)
            plt.text(
                event['date'],
                pattern_data.max().max(),
                event['description'],
                rotation = 90,
                alpha = 0.7,
                fontsize = 8
            )

        plt.title('Communication Pattern Evolution')
        plt.xlabel('Date')
        plt.ylabel('Pattern Frequency (% of messages)')
        plt.ylim(0, 1)
        plt.legend(title = 'Pattern')
        plt.tight_layout()

        if save_path:
            plt.savefig(save_path)

        return plt

    def plot_sentiment_timeline(self, time_unit = 'M', by_sender = True, save_path = None):
        """
        Plot sentiment analysis over time.

        Parameters:
        -----------
        time_unit : str
            Time unit for grouping ('D' for day, 'W' for week, 'M' for month)
        by_sender : bool
            Whether to split by sender
        save_path : str, optional
            Path to save the plot
        """
        if self.processed_data is None:
            print("No processed data available. Please call preprocess_data() first.")
            return None

        # Group by time unit
        if by_sender:
            sentiment_time_series = self.processed_data.groupby([
                pd.Grouper(key = 'DateTime', freq = time_unit), 'Sender'
            ])['Sentiment'].mean().unstack(fill_value = 0)
        else:
            sentiment_time_series = self.processed_data.groupby(
                pd.Grouper(key = 'DateTime', freq = time_unit)
            )['Sentiment'].mean()

        plt.figure(figsize=(14, 7))
        sentiment_time_series.plot(kind = 'line', marker = 'o')

        # Add medication period
        plt.axvspan(
            self.medication_timeline['start_date'],
            self.medication_timeline['end_date'],
            alpha = 0.2, color = 'gray', label = 'Medication Period'
        )

        # Add key events
        for event in self.key_events:
            plt.axvline(x = event['date'], color = 'r', linestyle = '--', alpha = 0.3)
            plt.text(
                event['date'],
                sentiment_time_series.max().max(),
                event['description'],
                rotation = 90,
                alpha = 0.7,
                fontsize = 8
            )

        plt.title('Message Sentiment Over Time')
        plt.xlabel('Date')
        plt.ylabel('Average Sentiment Score')
        if by_sender:
            plt.legend(title = 'Sender')
        plt.tight_layout()

        if save_path:
            plt.savefig(save_path)

        return plt

    def plot_pattern_correlation_heatmap(self, save_path = None):
        """
        Plot pattern correlation heatmap.

        Parameters:
        -----------
        save_path : str, optional
            Path to save the plot
        """
        if 'pattern_correlation' not in self.analysis_results:
            self.analyze_pattern_change_correlation()

        if 'pattern_correlation' not in self.analysis_results:
            print("Could not analyze pattern correlation.")
            return None

        correlation = self.analysis_results['pattern_correlation'].copy()

        # Clean column names
        correlation.columns = [col.replace('Contains', '') for col in correlation.columns]
        correlation.index = [idx.replace('Contains', '') for idx in correlation.index]

        plt.figure(figsize=(12, 10))
        sns.heatmap(
            correlation,
            annot = True,
            cmap = 'coolwarm',
            center = 0,
            linewidths=.5,
            fmt = '.2f'
        )

        plt.title('Pattern Correlation Matrix')
        plt.tight_layout()

        if save_path:
            plt.savefig(save_path)

        return plt

    def plot_word_clouds(self, period = 'During', save_path = None):
        """
        Plot word clouds for Amrita and Abhishek for a specific period.

        Parameters:
        -----------
        period : str
            Medication period ('Before', 'During', or 'After')
        save_path : str, optional
            Path to save the plot
        """
        if 'word_usage_trends' not in self.analysis_results:
            self.extract_word_usage_trends()

        if 'word_usage_trends' not in self.analysis_results:
            print("Could not extract word usage trends.")
            return None

        word_usage = self.analysis_results['word_usage_trends']

        # Check if data exists for the requested period
        amrita_key = f"{period}_Amrita"
        abhishek_key = f"{period}_Abhishek"

        if amrita_key not in word_usage or abhishek_key not in word_usage:
            print(f"No word usage data for {period} period.")
            return None

        # Convert to dictionary format for word cloud
        amrita_words = dict(word_usage[amrita_key])
        abhishek_words = dict(word_usage[abhishek_key])

        # Create figure with two subplots
        fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(20, 10))

        # Generate word clouds
        wc1 = WordCloud(background_color = 'white', max_words = 100, width = 800, height = 400).generate_from_frequencies(amrita_words)
        wc2 = WordCloud(background_color = 'white', max_words = 100, width = 800, height = 400).generate_from_frequencies(abhishek_words)

        # Display word clouds
        ax1.imshow(wc1, interpolation = 'bilinear')
        ax1.axis('off')
        ax1.set_title(f"Amrita's Words ({period} Medication)")

        ax2.imshow(wc2, interpolation = 'bilinear')
        ax2.axis('off')
        ax2.set_title(f"Abhishek's Words ({period} Medication)")

        plt.tight_layout()

        if save_path:
            plt.savefig(save_path)

        return plt

    def plot_medication_period_comparison(self, for_sender = 'Amrita', metrics = None, save_path = None):
        """
        Plot comparison of key metrics across medication periods.

        Parameters:
        -----------
        for_sender : str
            Which sender to analyze ('Amrita' or 'Abhishek')
        metrics : list, optional
            List of metrics to include (defaults to pattern frequencies)
        save_path : str, optional
            Path to save the plot
        """
        if 'medication_period_changes' not in self.analysis_results:
            self.analyze_medication_period_changes()

        if 'medication_period_changes' not in self.analysis_results:
            print("Could not analyze medication period changes.")
            return None

        period_metrics = self.analysis_results['medication_period_changes']['period_metrics']

        if for_sender not in period_metrics:
            print(f"No data for sender: {for_sender}")
            return None

        sender_metrics = period_metrics[for_sender]

        # Default to pattern frequencies if no metrics specified
        if metrics is None:
            metrics = [f'{pattern}_frequency' for pattern in self.patterns]

        # Prepare data for plotting
        periods = list(sender_metrics.keys())
        data = []

        for metric in metrics:
            metric_values = []
            for period in periods:
                if period in sender_metrics and metric in sender_metrics[period]:
                    metric_values.append(sender_metrics[period][metric])
                else:
                    metric_values.append(0)

            data.append({
                'metric': metric,
                'values': metric_values
            })

        # Create figure
        plt.figure(figsize=(14, 10))

        # Plot each metric
        bar_width = 0.8 / len(data)

        for i, metric_data in enumerate(data):
            x = np.arange(len(periods))
            offset = i * bar_width - (len(data) - 1) * bar_width / 2

            plt.bar(
                x + offset,
                metric_data['values'],
                width = bar_width,
                label = metric_data['metric'].replace('_frequency', '').title()
            )

        plt.xlabel('Medication Period')
        plt.ylabel('Value')
        plt.title(f'Communication Metrics Across Medication Periods for {for_sender}')
        plt.xticks(np.arange(len(periods)), periods)
        plt.legend()
        plt.tight_layout()

        if save_path:
            plt.savefig(save_path)

        return plt

    def export_to_json(self, file_path):
        """
        Export analysis results to a JSON file.

        Parameters:
        -----------
        file_path : str
            Path to save the JSON file
        """
        # Generate report
        report = self.generate_comprehensive_report()

        # Convert numpy and pandas objects to Python native types
        def convert_for_json(obj):
            if isinstance(obj, (np.integer, np.floating, np.bool_)):
                return obj.item()
            elif isinstance(obj, (datetime, np.datetime64)):
                return obj.isoformat()
            elif isinstance(obj, (list, tuple)):
                return [convert_for_json(x) for x in obj]
            elif isinstance(obj, dict):
                return {k: convert_for_json(v) for k, v in obj.items()}
            elif isinstance(obj, np.ndarray):
                return obj.tolist()
            elif pd.isna(obj):
                return None
            else:
                return obj

        # Convert the report
        json_report = convert_for_json(report)

        # Write to file
        try:
            with open(file_path, 'w') as f:
                json.dump(json_report, f, indent = 2)
            print(f"Analysis exported to {file_path}")
            return True
        except Exception as e:
            print(f"Error exporting analysis: {e}")
            return False


# Example usage
def main():
    # Initialize extractor
    extractor = WhatsAppPatternExtractor(
        medication_timeline={
            'start_date': datetime(2024, 3, 1),
            'end_date': datetime(2024, 11, 30)
        }
    )

    # Add key events
    extractor.add_key_event("2024-03-01", "SSRI initiated", "medical")
    extractor.add_key_event("2024-05-25", "First emotional distance", "relationship")
    extractor.add_key_event("2024-06-30", "Critical relationship point", "relationship")
    extractor.add_key_event("2024-10-14", "Left home", "relationship")
    extractor.add_key_event("2024-11-30", "SSRI discontinued", "medical")
    extractor.add_key_event("2025-01-26", "2D thinking described", "processing")

    # Load and preprocess data
    extractor.load_data("WhatsApp_Chat_2019_.csv")
    extractor.preprocess_data()

    # Run analyses
    extractor.analyze_message_frequency()
    extractor.analyze_pattern_frequency()
    extractor.analyze_sentiment_by_period()
    extractor.analyze_response_times()
    extractor.extract_word_usage_trends()
    extractor.analyze_pattern_change_correlation()
    extractor.analyze_gold_issue_pattern()
    extractor.analyze_2d_thinking_references()
    extractor.extract_communication_style_changes()
    extractor.analyze_medication_period_changes()

    # Generate visualizations
    extractor.plot_message_frequency(save_path = "message_frequency.png")
    extractor.plot_pattern_evolution(save_path = "pattern_evolution.png")
    extractor.plot_sentiment_timeline(save_path = "sentiment_timeline.png")
    extractor.plot_pattern_correlation_heatmap(save_path = "pattern_correlation.png")
    extractor.plot_word_clouds(period = "During", save_path = "word_clouds_during.png")
    extractor.plot_medication_period_comparison(save_path = "medication_period_comparison.png")

    # Export results
    extractor.export_to_json("whatsapp_pattern_analysis.json")

    # Print summary
    report = extractor.generate_comprehensive_report()
    print("Analysis complete!")
    print(f"Total messages: {report['data_summary']['total_messages']}")
    print(f"Date range: {report['data_summary']['date_range'][0]} to {report['data_summary']['date_range'][1]}")

    if 'gold_issue' in report['key_findings']:
        print(f"Gold issue first mentioned: {report['key_findings']['gold_issue']['first_mention']}")

    if '2d_thinking' in report['key_findings']:
        print(f"2D thinking first mentioned: {report['key_findings']['2d_thinking']['first_mention']}")


if __name__ == "__main__":
    main()

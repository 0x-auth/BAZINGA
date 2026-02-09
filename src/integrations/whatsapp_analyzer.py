#!/usr/bin/env python3
"""
WhatsApp Chat Analyzer for God Vision Dashboard
Integrates with CHRONOS-ANAMNESIS phi-resonant system
"""

import os
import re
import json
import datetime
import argparse
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import LinearSegmentedColormap
import matplotlib.dates as mdates
from collections import Counter
import networkx as nx
from wordcloud import WordCloud
import nltk
from nltk.sentiment import SentimentIntensityAnalyzer
from nltk.tokenize import word_tokenize
from nltk.corpus import stopwords

# Constants
PHI = 1.618033988749895
PHI_INVERSE = 0.618033988749895
DODO_PATTERN = [5, 1, 1, 2, 3, 4, 5, 1]

# Initialize NLTK components
try:
    nltk.data.find('tokenizers/punkt')
    nltk.data.find('sentiment/vader_lexicon.zip')
    nltk.data.find('corpora/stopwords')
except LookupError:
    print("Downloading NLTK resources...")
    nltk.download('punkt')
    nltk.download('vader_lexicon')
    nltk.download('stopwords')

# Message pattern for WhatsApp export format
WHATSAPP_MSG_PATTERN = r'\[?(\d{1,2}/\d{1,2}/\d{2,4}),? (\d{1,2}:\d{2}(?::\d{2})?(?: [AP]M)?)\]? - ([^:]+): (.+)'

class WhatsAppAnalyzer:
    """Analyzes WhatsApp chat exports to create phi-resonant patterns and insights"""
    
    def __init__(self, export_path=None):
        """Initialize the analyzer"""
        self.export_path = export_path
        self.messages = []
        self.messages_df = None
        self.date_format = None
        self.first_date = None
        self.last_date = None
        self.duration_days = None
        self.participants = []
        self.phi_boundaries = []
        self.sentiment_analyzer = SentimentIntensityAnalyzer()
        self.output_folder = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'whatsapp_analysis')
        
        # Create output folder if it doesn't exist
        if not os.path.exists(self.output_folder):
            os.makedirs(self.output_folder)
            
    def load_chat(self, filepath):
        """Load WhatsApp chat export file"""
        print(f"Loading chat from: {filepath}")
        self.export_path = filepath
        
        try:
            with open(filepath, 'r', encoding='utf-8') as file:
                chat_text = file.read()
        except UnicodeDecodeError:
            # Try another encoding if UTF-8 fails
            with open(filepath, 'r', encoding='iso-8859-1') as file:
                chat_text = file.read()
                
        # Determine date format
        if re.search(r'\d{1,2}/\d{1,2}/\d{2,4}', chat_text):
            # Check if format is MM/DD/YYYY or DD/MM/YYYY
            first_date_match = re.search(r'(\d{1,2})/(\d{1,2})/(\d{2,4})', chat_text)
            if first_date_match:
                month, day, year = first_date_match.groups()
                # Assume DD/MM/YYYY if day > 12
                if int(day) > 12:
                    self.date_format = "%d/%m/%Y"
                else:
                    self.date_format = "%m/%d/%Y"
            else:
                self.date_format = "%d/%m/%Y"  # Default
        else:
            self.date_format = "%Y-%m-%d"  # ISO format
                
        # Extract messages
        self.messages = []
        for match in re.finditer(WHATSAPP_MSG_PATTERN, chat_text):
            date_str, time_str, sender, message = match.groups()
            
            # Parse date
            try:
                if self.date_format == "%d/%m/%Y" or self.date_format == "%m/%d/%Y":
                    if len(date_str.split('/')[-1]) == 2:  # Short year format (YY)
                        date_str = date_str.rsplit('/', 1)[0] + '/20' + date_str.rsplit('/', 1)[1]
                date = datetime.datetime.strptime(date_str, self.date_format).date()
            except ValueError:
                # Try alternate format
                try:
                    alternate_format = "%m/%d/%Y" if self.date_format == "%d/%m/%Y" else "%d/%m/%Y"
                    date = datetime.datetime.strptime(date_str, alternate_format).date()
                    self.date_format = alternate_format  # Update format
                except ValueError:
                    print(f"Could not parse date: {date_str}")
                    continue
            
            # Parse time
            try:
                if "AM" in time_str or "PM" in time_str:
                    time = datetime.datetime.strptime(time_str, "%I:%M %p").time()
                else:
                    time = datetime.datetime.strptime(time_str, "%H:%M").time()
            except ValueError:
                try:
                    time = datetime.datetime.strptime(time_str, "%H:%M:%S").time()
                except ValueError:
                    print(f"Could not parse time: {time_str}")
                    continue
            
            # Create datetime
            timestamp = datetime.datetime.combine(date, time)
            
            # Add message to list
            self.messages.append({
                'timestamp': timestamp,
                'sender': sender.strip(),
                'message': message.strip(),
                'day_of_week': timestamp.strftime('%A'),
                'hour': timestamp.hour
            })
            
        # Create DataFrame
        self.messages_df = pd.DataFrame(self.messages)
        
        # Set first and last date
        if not self.messages_df.empty:
            self.first_date = self.messages_df['timestamp'].min()
            self.last_date = self.messages_df['timestamp'].max()
            self.duration_days = (self.last_date - self.first_date).days
            
            # Get participants
            self.participants = self.messages_df['sender'].unique().tolist()
            
            # Calculate phi-resonant boundaries
            self.calculate_phi_boundaries()
            
            print(f"Loaded {len(self.messages)} messages from {len(self.participants)} participants")
            print(f"Date range: {self.first_date.date()} to {self.last_date.date()} ({self.duration_days} days)")
        
        return self.messages_df
    
    def calculate_phi_boundaries(self):
        """Calculate phi-resonant boundary dates in the timeline"""
        if self.first_date and self.last_date:
            total_seconds = (self.last_date - self.first_date).total_seconds()
            
            # Calculate boundaries using phi and inverse phi
            phi_point = self.first_date + datetime.timedelta(seconds=total_seconds * PHI_INVERSE)
            inv_phi_point = self.first_date + datetime.timedelta(seconds=total_seconds * (1 - PHI_INVERSE))
            
            # Add points to list
            self.phi_boundaries = [
                {"position": PHI_INVERSE, "date": phi_point, "type": "φ⁻¹"},
                {"position": (1 - PHI_INVERSE), "date": inv_phi_point, "type": "1-φ⁻¹"}
            ]
            
            # Add DODO pattern points
            dodo_total = len(DODO_PATTERN)
            for i, value in enumerate(DODO_PATTERN):
                position = i / dodo_total
                date = self.first_date + datetime.timedelta(seconds=total_seconds * position)
                self.phi_boundaries.append({
                    "position": position,
                    "date": date,
                    "type": f"DODO-{value}"
                })
    
    def add_sentiment_analysis(self):
        """Add sentiment analysis to the messages dataframe"""
        if self.messages_df is None or self.messages_df.empty:
            print("No messages loaded. Load chat first.")
            return
        
        print("Performing sentiment analysis...")
        
        # Function to calculate sentiment
        def get_sentiment(text):
            scores = self.sentiment_analyzer.polarity_scores(text)
            return scores['compound']
        
        # Apply to all messages
        self.messages_df['sentiment'] = self.messages_df['message'].apply(get_sentiment)
        
        # Categorize sentiment
        self.messages_df['sentiment_category'] = pd.cut(
            self.messages_df['sentiment'],
            bins=[-1, -0.5, -0.1, 0.1, 0.5, 1],
            labels=['very negative', 'negative', 'neutral', 'positive', 'very positive']
        )
        
        print("Sentiment analysis complete.")
        return self.messages_df
    
    def create_timeseries_chart(self, output_file=None):
        """Create time series chart of message frequency and sentiment"""
        if self.messages_df is None or self.messages_df.empty:
            print("No messages loaded. Load chat first.")
            return
        
        print("Creating time series chart...")
        
        # Ensure sentiment is calculated
        if 'sentiment' not in self.messages_df.columns:
            self.add_sentiment_analysis()
        
        # Create daily message count and average sentiment
        daily_data = self.messages_df.groupby(self.messages_df['timestamp'].dt.date).agg({
            'message': 'count',
            'sentiment': 'mean'
        })
        daily_data.columns = ['message_count', 'avg_sentiment']
        
        # Calculate 7-day rolling averages
        daily_data['message_count_rolling'] = daily_data['message_count'].rolling(window=7).mean()
        daily_data['avg_sentiment_rolling'] = daily_data['sentiment'].rolling(window=7).mean()
        
        # Create the figure
        fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(12, 8), sharex=True)
        fig.suptitle('WhatsApp Chat Analysis: Time Series', fontsize=16)
        
        # Plot message count
        ax1.plot(daily_data.index, daily_data['message_count'], 'b-', alpha=0.3, label='Daily Count')
        ax1.plot(daily_data.index, daily_data['message_count_rolling'], 'b-', linewidth=2, label='7-day Avg')
        ax1.set_ylabel('Message Count')
        ax1.legend()
        ax1.grid(True, alpha=0.3)
        
        # Plot sentiment
        ax2.plot(daily_data.index, daily_data['avg_sentiment'], 'g-', alpha=0.3, label='Daily Sentiment')
        ax2.plot(daily_data.index, daily_data['avg_sentiment_rolling'], 'g-', linewidth=2, label='7-day Avg')
        ax2.set_ylabel('Sentiment (-1 to 1)')
        ax2.set_ylim(-1, 1)
        ax2.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
        ax2.legend()
        ax2.grid(True, alpha=0.3)
        
        # Format x-axis
        ax2.xaxis.set_major_formatter(mdates.DateFormatter('%Y-%m-%d'))
        ax2.xaxis.set_major_locator(mdates.MonthLocator(interval=1))
        plt.xticks(rotation=45)
        
        # Add phi-resonant boundary markers
        for boundary in self.phi_boundaries:
            date = boundary['date'].date()
            if date in daily_data.index:
                ax1.axvline(x=date, color='purple', linestyle='--', alpha=0.5)
                ax2.axvline(x=date, color='purple', linestyle='--', alpha=0.5)
                ax1.text(date, ax1.get_ylim()[1] * 0.9, boundary['type'], 
                        rotation=90, verticalalignment='top')
        
        plt.tight_layout()
        
        # Save or display
        if output_file:
            plt.savefig(output_file)
            print(f"Time series chart saved to {output_file}")
        else:
            output_path = os.path.join(self.output_folder, 'timeseries_chart.png')
            plt.savefig(output_path)
            print(f"Time series chart saved to {output_path}")
        
        plt.close()
        
        return daily_data
    
    def create_heatmap(self, output_file=None):
        """Create message frequency heatmap by day and hour"""
        if self.messages_df is None or self.messages_df.empty:
            print("No messages loaded. Load chat first.")
            return
        
        print("Creating message frequency heatmap...")
        
        # Extract day of week and hour
        self.messages_df['day_name'] = self.messages_df['timestamp'].dt.day_name()
        self.messages_df['hour'] = self.messages_df['timestamp'].dt.hour
        
        # Define order of days
        days_order = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
        
        # Create pivot table
        heatmap_data = pd.pivot_table(
            self.messages_df, 
            values='message', 
            index='day_name',
            columns='hour', 
            aggfunc='count', 
            fill_value=0
        )
        
        # Reorder days
        heatmap_data = heatmap_data.reindex(days_order)
        
        # Create the heatmap
        plt.figure(figsize=(12, 6))
        
        # Custom colormap with phi-resonant colors
        colors = [(0.7, 0.5, 0.9), (0.3, 0.2, 0.8), (0.1, 0.1, 0.7)]  # Purple to blue
        cmap = LinearSegmentedColormap.from_list('phi_cmap', colors, N=100)
        
        ax = plt.subplot(111)
        im = ax.imshow(heatmap_data, cmap=cmap)
        
        # Set labels
        ax.set_xticks(np.arange(24))
        ax.set_xticklabels([f"{h}:00" for h in range(24)])
        ax.set_yticks(np.arange(len(days_order)))
        ax.set_yticklabels(days_order)
        
        # Add colorbar
        cbar = plt.colorbar(im)
        cbar.set_label('Message Count')
        
        plt.title('Message Frequency by Day and Hour', fontsize=16)
        plt.xlabel('Hour of Day')
        plt.tight_layout()
        
        # Save or display
        if output_file:
            plt.savefig(output_file)
            print(f"Heatmap saved to {output_file}")
        else:
            output_path = os.path.join(self.output_folder, 'message_heatmap.png')
            plt.savefig(output_path)
            print(f"Heatmap saved to {output_path}")
        
        plt.close()
        
        return heatmap_data
    
    def create_word_cloud(self, sender=None, output_file=None):
        """Create word cloud from messages"""
        if self.messages_df is None or self.messages_df.empty:
            print("No messages loaded. Load chat first.")
            return
        
        print("Creating word cloud...")
        
        # Filter by sender if specified
        if sender:
            text_data = ' '.join(self.messages_df[self.messages_df['sender'] == sender]['message'])
            title_suffix = f" - {sender}"
        else:
            text_data = ' '.join(self.messages_df['message'])
            title_suffix = ""
        
        # Process text
        stop_words = set(stopwords.words('english'))
        stop_words.update(['https', 'http', 'www', 'com', 'image', 'omitted', 'Media'])
        
        # Tokenize and filter text
        words = word_tokenize(text_data)
        filtered_words = [word.lower() for word in words if word.isalpha() and word.lower() not in stop_words]
        text_data = ' '.join(filtered_words)
        
        # Generate word cloud
        wordcloud = WordCloud(
            width=800, 
            height=400,
            background_color='white', 
            max_words=100
        ).generate(text_data)
        
        # Create plot
        plt.figure(figsize=(10, 5))
        plt.imshow(wordcloud, interpolation='bilinear')
        plt.axis('off')
        plt.title(f"Word Cloud{title_suffix}", fontsize=16)
        plt.tight_layout()
        
        # Save or display
        if output_file:
            plt.savefig(output_file)
            print(f"Word cloud saved to {output_file}")
        else:
            sender_suffix = f"_{sender.replace(' ', '_')}" if sender else ""
            output_path = os.path.join(self.output_folder, f'wordcloud{sender_suffix}.png')
            plt.savefig(output_path)
            print(f"Word cloud saved to {output_path}")
        
        plt.close()
    
    def create_radar_chart(self, output_file=None):
        """Create radar chart of communication patterns aligned with DODO pattern"""
        if self.messages_df is None or self.messages_df.empty:
            print("No messages loaded. Load chat first.")
            return
        
        print("Creating DODO pattern radar chart...")
        
        # Ensure sentiment is calculated
        if 'sentiment' not in self.messages_df.columns:
            self.add_sentiment_analysis()
            
        # Create normalized time periods based on DODO pattern
        duration = (self.last_date - self.first_date).total_seconds()
        period_duration = duration / len(DODO_PATTERN)
        
        # Initialize metrics for each period
        periods = []
        for i, value in enumerate(DODO_PATTERN):
            start_time = self.first_date + datetime.timedelta(seconds=i * period_duration)
            end_time = self.first_date + datetime.timedelta(seconds=(i + 1) * period_duration)
            
            # Filter messages in this period
            period_messages = self.messages_df[
                (self.messages_df['timestamp'] >= start_time) & 
                (self.messages_df['timestamp'] < end_time)
            ]
            
            # Calculate metrics
            message_count = len(period_messages)
            avg_sentiment = period_messages['sentiment'].mean() if not period_messages.empty else 0
            unique_days = period_messages['timestamp'].dt.date.nunique() if not period_messages.empty else 0
            
            # Normalize between 0 and 1
            max_msgs = self.messages_df.groupby(pd.Grouper(key='timestamp', freq='D')).size().max()
            normalized_count = message_count / (max_msgs * 30) if max_msgs > 0 else 0
            normalized_sentiment = (avg_sentiment + 1) / 2  # Convert from [-1,1] to [0,1]
            normalized_days = unique_days / 30 if period_duration > 0 else 0
            
            periods.append({
                'period': i + 1,
                'dodo_value': value,
                'message_count': message_count,
                'avg_sentiment': avg_sentiment,
                'unique_days': unique_days,
                'normalized_count': min(normalized_count, 1),
                'normalized_sentiment': normalized_sentiment,
                'normalized_days': min(normalized_days, 1)
            })
        
        # Create radar chart
        fig = plt.figure(figsize=(10, 10))
        ax = fig.add_subplot(111, polar=True)
        
        # Set up the radar chart
        angles = np.linspace(0, 2*np.pi, len(DODO_PATTERN), endpoint=False).tolist()
        angles += angles[:1]  # Close the loop
        
        # Prepare data
        metrics = ['normalized_count', 'normalized_sentiment', 'normalized_days']
        metric_labels = ['Message Frequency', 'Positive Sentiment', 'Consistency']
        colors = ['b', 'g', 'r']
        
        # Add data to chart
        for i, metric in enumerate(metrics):
            values = [period[metric] for period in periods]
            values += values[:1]  # Close the loop
            ax.plot(angles, values, color=colors[i], linewidth=2, label=metric_labels[i])
            ax.fill(angles, values, color=colors[i], alpha=0.1)
        
        # Set labels
        ax.set_xticks(angles[:-1])
        ax.set_xticklabels([f"{i+1} ({val})" for i, val in enumerate(DODO_PATTERN)])
        
        # Set chart properties
        ax.set_yticklabels([])  # Hide radial labels
        ax.grid(True)
        plt.legend(loc='upper right', bbox_to_anchor=(0.1, 0.1))
        plt.title('DODO Pattern Alignment (5.1.1.2.3.4.5.1)', fontsize=16)
        
        # Save or display
        if output_file:
            plt.savefig(output_file)
            print(f"DODO radar chart saved to {output_file}")
        else:
            output_path = os.path.join(self.output_folder, 'dodo_radar_chart.png')
            plt.savefig(output_path)
            print(f"DODO radar chart saved to {output_path}")
        
        plt.close()
        
        return periods
    
    def calculate_interaction_network(self, output_file=None):
        """Calculate interaction network between participants"""
        if self.messages_df is None or self.messages_df.empty or len(self.participants) < 2:
            print("Not enough participants for interaction network.")
            return
        
        print("Calculating interaction network...")
        
        # Create a directed graph
        G = nx.DiGraph()
        
        # Add nodes (participants)
        for participant in self.participants:
            G.add_node(participant)
        
        # Calculate interactions
        participant_counts = {}
        for sender in self.participants:
            # Count messages from this sender
            sender_messages = self.messages_df[self.messages_df['sender'] == sender]
            count = len(sender_messages)
            participant_counts[sender] = count
            
            # Calculate message sentiment
            if 'sentiment' not in self.messages_df.columns:
                self.add_sentiment_analysis()
            avg_sentiment = sender_messages['sentiment'].mean() if not sender_messages.empty else 0
            
            # Add attributes to node
            G.nodes[sender]['messages'] = count
            G.nodes[sender]['sentiment'] = avg_sentiment
        
        # Get replies (mentioned in messages)
        for participant in self.participants:
            for other in self.participants:
                if participant == other:
                    continue
                
                # Count mentions and patterns that indicate replies
                mentions = self.messages_df[
                    (self.messages_df['sender'] == participant) & 
                    (self.messages_df['message'].str.contains(other, regex=False, case=False))
                ].shape[0]
                
                if mentions > 0:
                    G.add_edge(participant, other, weight=mentions)
        
        # Plot the network
        plt.figure(figsize=(10, 8))
        
        # Node sizes based on message count
        node_sizes = [participant_counts.get(p, 10) * 0.5 for p in G.nodes()]
        
        # Node colors based on sentiment
        node_colors = [G.nodes[p].get('sentiment', 0) for p in G.nodes()]
        
        # Create colormap
        cmap = plt.cm.coolwarm
        
        # Draw the graph
        pos = nx.spring_layout(G, seed=42)
        nx.draw_networkx_nodes(G, pos, node_size=node_sizes, node_color=node_colors, cmap=cmap, alpha=0.8)
        
        # Draw edges with varying width
        for (u, v, d) in G.edges(data=True):
            width = d.get('weight', 1) * 0.5
            nx.draw_networkx_edges(G, pos, edgelist=[(u, v)], width=width, alpha=0.6)
        
        # Draw labels
        nx.draw_networkx_labels(G, pos, font_size=10)
        
        plt.axis('off')
        plt.title('Interaction Network', fontsize=16)
        
        # Add colorbar legend for sentiment
        sm = plt.cm.ScalarMappable(cmap=cmap)
        sm.set_array(node_colors)
        plt.colorbar(sm, label='Sentiment (-1 to 1)')
        
        # Save or display
        if output_file:
            plt.savefig(output_file)
            print(f"Interaction network saved to {output_file}")
        else:
            output_path = os.path.join(self.output_folder, 'interaction_network.png')
            plt.savefig(output_path)
            print(f"Interaction network saved to {output_path}")
        
        plt.close()
        
        return G
    
    def calculate_phi_resonant_events(self, num_events=10):
        """Find events at phi-resonant points in the timeline"""
        if self.messages_df is None or self.messages_df.empty:
            print("No messages loaded. Load chat first.")
            return []
        
        print("Calculating phi-resonant events...")
        
        # Calculate phi-resonant points if not already done
        if not self.phi_boundaries:
            self.calculate_phi_boundaries()
        
        # Find messages near phi-resonant points
        phi_events = []
        for boundary in self.phi_boundaries:
            boundary_date = boundary['date']
            
            # Find closest messages (within 12 hours)
            window = datetime.timedelta(hours=12)
            nearby_messages = self.messages_df[
                (self.messages_df['timestamp'] >= boundary_date - window) &
                (self.messages_df['timestamp'] <= boundary_date + window)
            ]
            
            if not nearby_messages.empty:
                # Sort by closeness to boundary
                nearby_messages['time_diff'] = abs((nearby_messages['timestamp'] - boundary_date).dt.total_seconds())
                nearby_messages = nearby_messages.sort_values('time_diff')
                
                # Take top messages
                top_messages = nearby_messages.head(3)
                
                for _, msg in top_messages.iterrows():
                    phi_events.append({
                        'timestamp': msg['timestamp'],
                        'sender': msg['sender'],
                        'message': msg['message'],
                        'boundary_type': boundary['type'],
                        'time_diff_hours': msg['time_diff'] / 3600,
                        'position': boundary['position']
                    })
        
        # Sort by position and time difference
        phi_events.sort(key=lambda x: (x['position'], x['time_diff_hours']))
        
        # Return top events
        return phi_events[:num_events]
    
    def generate_summary_statistics(self):
        """Generate summary statistics for the chat"""
        if self.messages_df is None or self.messages_df.empty:
            print("No messages loaded. Load chat first.")
            return {}
        
        print("Generating summary statistics...")
        
        # Basic statistics
        total_messages = len(self.messages_df)
        total_days = self.duration_days
        avg_msgs_per_day = total_messages / total_days if total_days > 0 else 0
        
        # Message count by sender
        sender_counts = self.messages_df['sender'].value_counts().to_dict()
        
        # Most active days
        daily_counts = self.messages_df.groupby(self.messages_df['timestamp'].dt.date).size()
        most_active_date = daily_counts.idxmax()
        max_daily_count = daily_counts.max()
        
        # Most active hours
        hourly_counts = self.messages_df.groupby(self.messages_df['timestamp'].dt.hour).size()
        most_active_hour = hourly_counts.idxmax()
        
        # Sentiment if available
        sentiment_stats = {}
        if 'sentiment' in self.messages_df.columns:
            avg_sentiment = self.messages_df['sentiment'].mean()
            sentiment_dist = self.messages_df['sentiment_category'].value_counts(normalize=True).to_dict()
            
            # Most positive/negative messages
            most_positive = self.messages_df.loc[self.messages_df['sentiment'].idxmax()]
            most_negative = self.messages_df.loc[self.messages_df['sentiment'].idxmin()]
            
            sentiment_stats = {
                'average_sentiment': avg_sentiment,
                'sentiment_distribution': sentiment_dist,
                'most_positive_message': {
                    'timestamp': most_positive['timestamp'],
                    'sender': most_positive['sender'],
                    'message': most_positive['message'],
                    'sentiment': most_positive['sentiment']
                },
                'most_negative_message': {
                    'timestamp': most_negative['timestamp'],
                    'sender': most_negative['sender'],
                    'message': most_negative['message'],
                    'sentiment': most_negative['sentiment']
                }
            }
        
        # Phi-resonant events
        phi_events = self.calculate_phi_resonant_events(5)
        
        # Media counts
        media_count = len(self.messages_df[self.messages_df['message'].str.contains('<Media omitted>', case=False)])
        
        # Day of week distribution
        day_dist = self.messages_df['day_of_week'].value_counts(normalize=True).to_dict()
        
        # Compile statistics
        stats = {
            'total_messages': total_messages,
            'duration_days': total_days,
            'avg_messages_per_day': avg_msgs_per_day,
            'participant_counts': sender_counts,
            'most_active_date': {
                'date': most_active_date.strftime('%Y-%m-%d'),
                'count': int(max_daily_count)
            },
            'most_active_hour': {
                'hour': most_active_hour,
                'count': int(hourly_counts[most_active_hour])
            },
            'media_count': media_count,
            'day_distribution': day_dist,
            'phi_resonant_events': phi_events,
            **sentiment_stats
        }
        
        return stats
    
    def generate_html_report(self, output_file=None):
        """Generate HTML report with visualizations and analysis"""
        if self.messages_df is None or self.messages_df.empty:
            print("No messages loaded. Load chat first.")
            return
        
        print("Generating HTML report...")
        
        # Create visualizations
        timeseries_path = os.path.join(self.output_folder, 'timeseries_chart.png')
        heatmap_path = os.path.join(self.output_folder, 'message_heatmap.png')
        wordcloud_path = os.path.join(self.output_folder, 'wordcloud.png')
        dodo_path = os.path.join(self.output_folder, 'dodo_radar_chart.png')
        network_path = os.path.join(self.output_folder, 'interaction_network.png')
        
        self.create_timeseries_chart(timeseries_path)
        self.create_heatmap(heatmap_path)
        self.create_word_cloud(output_file=wordcloud_path)
        self.create_radar_chart(dodo_path)
        
        if len(self.participants) > 1:
            self.calculate_interaction_network(network_path)
        
        # Get statistics
        stats = self.generate_summary_statistics()
        
        # Create HTML report
        html_content = f"""
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>WhatsApp Analysis - Phi-Resonant Patterns</title>
            <style>
                body {{
                    font-family: Arial, sans-serif;
                    line-height: 1.6;
                    margin: 0;
                    padding: 20px;
                    color: #333;
                    background-color: #f5f7fa;
                }}
                .container {{
                    max-width: 1200px;
                    margin: 0 auto;
                    background-color: white;
                    padding: 20px;
                    border-radius: 8px;
                    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
                }}
                h1, h2, h3 {{
                    color: #2c3e50;
                }}
                h1 {{
                    text-align: center;
                    margin-bottom: 30px;
                    border-bottom: 2px solid #3498db;
                    padding-bottom: 10px;
                }}
                .section {{
                    margin-bottom: 40px;
                }}
                .image-container {{
                    text-align: center;
                    margin: 20px 0;
                }}
                img {{
                    max-width: 100%;
                    border-radius: 4px;
                    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
                }}
                table {{
                    width: 100%;
                    border-collapse: collapse;
                    margin: 20px 0;
                }}
                th, td {{
                    padding: 10px;
                    border: 1px solid #ddd;
                    text-align: left;
                }}
                th {{
                    background-color: #f2f2f2;
                }}
                .phi-highlight {{
                    background-color: #e6e6fa;
                    padding: 5px;
                    border-radius: 3px;
                    font-weight: bold;
                    color: #483d8b;
                }}
                .grid-container {{
                    display: grid;
                    grid-template-columns: 1fr 1fr;
                    gap: 20px;
                }}
                .footer {{
                    text-align: center;
                    margin-top: 40px;
                    padding-top: 20px;
                    border-top: 1px solid #ddd;
                    font-size: 0.9em;
                    color: #777;
                }}
                @media (max-width: 768px) {{
                    .grid-container {{
                        grid-template-columns: 1fr;
                    }}
                }}
            </style>
        </head>
        <body>
            <div class="container">
                <h1>WhatsApp Analysis: Phi-Resonant Patterns</h1>
                
                <div class="section">
                    <h2>📊 Summary Statistics</h2>
                    <div class="grid-container">
                        <div>
                            <h3>Basic Information</h3>
                            <table>
                                <tr><th>Total Messages</th><td>{stats['total_messages']}</td></tr>
                                <tr><th>Date Range</th><td>{self.first_date.strftime('%Y-%m-%d')} to {self.last_date.strftime('%Y-%m-%d')}</td></tr>
                                <tr><th>Duration</th><td>{stats['duration_days']} days</td></tr>
                                <tr><th>Avg. Messages/Day</th><td>{stats['avg_messages_per_day']:.2f}</td></tr>
                                <tr><th>Media Shared</th><td>{stats['media_count']}</td></tr>
                                <tr><th>Total Participants</th><td>{len(self.participants)}</td></tr>
                            </table>
                        </div>
                        
                        <div>
                            <h3>Activity Patterns</h3>
                            <table>
                                <tr><th>Most Active Date</th><td>{stats['most_active_date']['date']} ({stats['most_active_date']['count']} messages)</td></tr>
                                <tr><th>Most Active Hour</th><td>{stats['most_active_hour']['hour']}:00 ({stats['most_active_hour']['count']} messages)</td></tr>
                            </table>
                            
                            <h3>Participant Message Counts</h3>
                            <table>
                                <tr><th>Participant</th><th>Messages</th><th>Percentage</th></tr>
                                {
                                ''.join([f"<tr><td>{participant}</td><td>{count}</td><td>{count/stats['total_messages']*100:.1f}%</td></tr>" 
                                        for participant, count in sorted(stats['participant_counts'].items(), key=lambda x: x[1], reverse=True)])
                                }
                            </table>
                        </div>
                    </div>
                </div>
                
                <div class="section">
                    <h2>⏳ Timeline Analysis</h2>
                    <p>The following chart shows message frequency and sentiment over time, with key phi-resonant boundaries marked.</p>
                    <div class="image-container">
                        <img src="{os.path.basename(timeseries_path)}" alt="Time Series Chart">
                    </div>
                </div>
                
                <div class="section">
                    <h2>🌟 Phi-Resonant Events</h2>
                    <p>These messages occurred at or near mathematically significant points in the timeline, based on the golden ratio (φ = 1.618...).</p>
                    <table>
                        <tr><th>Date & Time</th><th>Sender</th><th>Message</th><th>Boundary</th></tr>
                        {
                        ''.join([f"<tr><td>{event['timestamp'].strftime('%Y-%m-%d %H:%M')}</td><td>{event['sender']}</td><td>{event['message'][:100]}{'...' if len(event['message']) > 100 else ''}</td><td class='phi-highlight'>{event['boundary_type']}</td></tr>" 
                                for event in stats['phi_resonant_events']])
                        }
                    </table>
                </div>
                
                <div class="section">
                    <h2>📱 Message Patterns</h2>
                    <div class="grid-container">
                        <div>
                            <h3>Message Frequency by Day and Hour</h3>
                            <div class="image-container">
                                <img src="{os.path.basename(heatmap_path)}" alt="Message Heatmap">
                            </div>
                        </div>
                        <div>
                            <h3>DODO Pattern Alignment (5.1.1.2.3.4.5.1)</h3>
                            <div class="image-container">
                                <img src="{os.path.basename(dodo_path)}" alt="DODO Pattern Alignment">
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="section">
                    <h2>💬 Content Analysis</h2>
                    {'<div class="grid-container">' if 'average_sentiment' in stats else ''}
                        <div>
                            <h3>Word Cloud</h3>
                            <div class="image-container">
                                <img src="{os.path.basename(wordcloud_path)}" alt="Word Cloud">
                            </div>
                        </div>
                        {'''
                        <div>
                            <h3>Sentiment Analysis</h3>
                            <table>
                                <tr><th>Average Sentiment</th><td>{:.2f} ({:+.2f})</td></tr>
                                <tr><th colspan="2">Sentiment Distribution</th></tr>
                                {}
                            </table>
                            <h4>Most Positive Message:</h4>
                            <p><strong>{}</strong> ({}):<br>{}</p>
                            <h4>Most Negative Message:</h4>
                            <p><strong>{}</strong> ({}):<br>{}</p>
                        </div>
                        '''.format(
                            stats['average_sentiment'], 
                            stats['average_sentiment'], 
                            ''.join([f"<tr><td>{category}</td><td>{percentage*100:.1f}%</td></tr>" 
                                    for category, percentage in stats['sentiment_distribution'].items()]),
                            stats['most_positive_message']['sender'],
                            stats['most_positive_message']['timestamp'].strftime('%Y-%m-%d %H:%M'),
                            stats['most_positive_message']['message'][:100] + ('...' if len(stats['most_positive_message']['message']) > 100 else ''),
                            stats['most_negative_message']['sender'],
                            stats['most_negative_message']['timestamp'].strftime('%Y-%m-%d %H:%M'),
                            stats['most_negative_message']['message'][:100] + ('...' if len(stats['most_negative_message']['message']) > 100 else '')
                        ) if 'average_sentiment' in stats else ''}
                    {'</div>' if 'average_sentiment' in stats else ''}
                    
                    {'''
                    <h3>Interaction Network</h3>
                    <div class="image-container">
                        <img src="{}" alt="Interaction Network">
                    </div>
                    '''.format(os.path.basename(network_path)) if len(self.participants) > 1 and os.path.exists(network_path) else ''}
                </div>
                
                <div class="footer">
                    <p>Generated with WhatsApp Analyzer - Phi-Resonant Pattern Analysis</p>
                    <p>DODO Pattern: 5.1.1.2.3.4.5.1 | φ = 1.618033988749895</p>
                    <p>Trust as Fifth Dimension</p>
                </div>
            </div>
        </body>
        </html>
        """
        
        # Save HTML report
        if output_file:
            report_path = output_file
        else:
            report_path = os.path.join(self.output_folder, 'whatsapp_analysis_report.html')
        
        with open(report_path, 'w', encoding='utf-8') as f:
            f.write(html_content)
        
        # Copy images to output folder if they're not already there
        for img_file in [timeseries_path, heatmap_path, wordcloud_path, dodo_path, network_path]:
            if os.path.exists(img_file):
                basename = os.path.basename(img_file)
                output_img_path = os.path.join(os.path.dirname(report_path), basename)
                if img_file != output_img_path:
                    import shutil
                    shutil.copy2(img_file, output_img_path)
        
        print(f"HTML report generated at {report_path}")
        return report_path
    
    def analyze_whatsapp_chat(self, filepath):
        """Run full analysis on WhatsApp chat export"""
        print(f"Analyzing WhatsApp chat: {filepath}")
        
        # Load chat
        self.load_chat(filepath)
        
        # Add sentiment analysis
        self.add_sentiment_analysis()
        
        # Generate visualizations and report
        report_path = self.generate_html_report()
        
        print(f"Analysis complete. Report generated at {report_path}")
        return report_path


def main():
    """Main function to run the analyzer from command line"""
    parser = argparse.ArgumentParser(description='Analyze WhatsApp chat exports using phi-resonant patterns')
    parser.add_argument('filepath', help='Path to WhatsApp chat export file (.txt)')
    args = parser.parse_args()
    
    analyzer = WhatsAppAnalyzer()
    analyzer.analyze_whatsapp_chat(args.filepath)


if __name__ == "__main__":
    main()